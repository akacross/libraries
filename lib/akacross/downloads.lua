local DownloadManager = {}
DownloadManager._VERSION = '0.1.0'
DownloadManager.__index = DownloadManager

local defaultMaxConcurrentDownloads = 10

local lanes = require('lanes')
lanes.configure()

if not _G['lanes.download_manager'] then
    local linda = lanes.linda()

    local download_lane_gen = lanes.gen('*', {
        package = {
            path = package.path,
            cpath = package.cpath,
        },
    },
    function(linda, taskType, fileUrl, filePath, identifier)
        local ltn12 = require('ltn12')       -- For HTTP progress sink
        local http = require('socket.http')  -- For HTTP requests
        local https = require('ssl.https')   -- For HTTPS requests
        local lfs = require('lfs')           -- LuaFileSystem
        local url = require('socket.url')    -- URL parsing

        if taskType == "download" then
            -- Ensure the output directory exists
            local dir = filePath:match("^(.*[/\\])")
            if dir and dir ~= "" then
                local attrs = lfs.attributes(dir)
                if not attrs then
                    local path = ""
                    for folder in string.gmatch(dir, "[^/\\]+[/\\]?") do
                        path = path .. folder
                        local attr = lfs.attributes(path)
                        if not attr then
                            local success, err = lfs.mkdir(path)
                            if not success then
                                linda:send('error_' .. identifier, { error = "Directory Creation Error: " .. tostring(err) })
                                return
                            end
                        end
                    end
                end
            end

            -- Prepare variables for progress tracking
            local progressData = {
                downloaded = 0,
                total = 0,
            }

            -- Create a sink that writes to the file and updates progress
            local outputFile, err = io.open(filePath, "wb")
            if not outputFile then
                linda:send('error_' .. identifier, { error = "File Open Error: " .. tostring(err) })
                return
            end

            -- Determine whether to use HTTP or HTTPS
            local parsed_url = url.parse(fileUrl)
            local http_request = http.request
            if parsed_url and parsed_url.scheme == "https" then
                http_request = https.request
            end

            -- Perform a HEAD request to get the total size
            local _, code, headers = http_request{
                url = fileUrl,
                method = "HEAD",
            }

            if code == 200 and headers then
                local contentLength = headers["content-length"] or headers["Content-Length"]
                if contentLength then
                    progressData.total = tonumber(contentLength)
                else
                    linda:send('error_' .. identifier, { error = "Content-Length header not found for URL: " .. fileUrl })
                end
            else
                linda:send('error_' .. identifier, { error = "HEAD request failed with code: " .. code .. " for URL: " .. fileUrl })
            end

            -- Create a custom sink function
            local stopDownload = false  -- Control variable
            local function progressSink(chunk, sinkErr)
                if stopDownload then
                    -- Do nothing if download should stop
                    return nil  -- Return nil to stop the sink
                end

                if chunk then
                    -- Write the chunk to the file
                    local success, writeErr = outputFile:write(chunk)
                    if not success then
                        linda:send('error_' .. identifier, { error = "File Write Error: " .. tostring(writeErr) })
                        stopDownload = true  -- Signal to stop further processing
                        -- Close the file to release resources
                        outputFile:close()
                        return nil  -- Return nil to stop the sink
                    else
                        -- Update progress
                        progressData.downloaded = progressData.downloaded + #chunk
                        linda:send('progress_' .. identifier, {
                            downloaded = progressData.downloaded,
                            total = progressData.total,
                        })
                    end
                else
                    -- No more data; close the file
                    outputFile:close()
                    linda:send('completed_' .. identifier, {
                        downloaded = progressData.downloaded,
                        total = progressData.total,
                    })
                end
                return 1  -- Continue processing
            end

            -- Use the custom sink in the HTTP request
            local requestSuccess, requestCode, requestHeaders, requestStatus = http_request{
                url = fileUrl,
                method = "GET",
                sink = progressSink,
                headers = {
                    ["Accept-Encoding"] = "identity",  -- Disable compression
                },
                redirect = false,
            }

            -- Handle unsuccessful requests
            if not requestSuccess or not (requestCode == 200 or requestCode == 206) then
                os.remove(filePath)  -- Remove incomplete file
                local errorMsg = "HTTP Error: " .. tostring(requestCode)
                linda:send('error_' .. identifier, { error = errorMsg })
            end

        elseif taskType == "fetch" then
            -- Determine whether to use HTTP or HTTPS
            local parsed_url = url.parse(fileUrl)
            local http_request = http.request
            if parsed_url and parsed_url.scheme == "https" then
                http_request = https.request
            end

            -- Perform the request
            local response_body = {}
            local res, code, response_headers, status = http_request{
                url = fileUrl,
                sink = ltn12.sink.table(response_body),
                headers = {
                    ["Accept-Encoding"] = "identity",  -- Disable compression
                }
            }

            if code == 200 then
                local content = table.concat(response_body)
                linda:send('completed_' .. identifier, { content = content })
            else
                local errorMsg = "HTTP Error: " .. tostring(code)
                linda:send('error_' .. identifier, { error = errorMsg })
            end
        end
    end)

    local main_lane_gen = lanes.gen('*', {
        package = {
            path = package.path,
            cpath = package.cpath,
        },
    },
    function(linda)
        while true do
            local key, val = linda:receive(0, 'request')
            if key == 'request' and val then
                local taskType = val.taskType
                local fileUrl = val.url
                local filePath = val.filePath
                local identifier = val.identifier

                local success, laneOrErr = pcall(download_lane_gen, linda, taskType, fileUrl, filePath, identifier)
                if not success then
                    linda:send('error_' .. identifier, { error = "Failed to start lane: " .. tostring(laneOrErr) })
                end
            end
        end
    end)

    local success, laneOrErr = pcall(main_lane_gen, linda)
    if success then
        _G['lanes.download_manager'] = { lane = laneOrErr, linda = linda }
    else
        print("Failed to start main lane:", laneOrErr)
    end
end

function DownloadManager:new(maxConcurrentDownloads)
    local manager = {
        downloadQueue = {},
        fetchQueue = {},
        downloadsInProgress = {},
        fetchesInProgress = {},
        activeDownloads = 0,
        activeFetches = 0,
        maxConcurrentDownloads = maxConcurrentDownloads or 5,
        isDownloading = false,
        isFetching = false,
        onCompleteCallback = nil,
        onProgressCallback = nil,
        totalFiles = 0,
        completedFiles = 0,
        lanesHttp = _G['lanes.download_manager'].linda,
        hasCompleted = false,
        pendingBatches = {},
        pendingFetchBatches = {},
    }
    setmetatable(manager, self)
    return manager
end

function DownloadManager:queueDownloads(fileTable, onComplete, onProgress)
    table.insert(self.pendingBatches, {files = fileTable, onComplete = onComplete, onProgress = onProgress})

    if not self.isDownloading then
        self:processNextBatch()
    end
end

function DownloadManager:processNextBatch()
    if #self.pendingBatches == 0 then
        return
    end

    local batch = table.remove(self.pendingBatches, 1)
    self.onCompleteCallback = batch.onComplete
    self.onProgressCallback = batch.onProgress

    self.hasCompleted = false
    self.totalFiles = 0
    self.completedFiles = 0
    self.downloadQueue = {}
    self.downloadsInProgress = {}
    self.activeDownloads = 0

    for index, file in ipairs(batch.files) do
        if not doesFileExist(file.path) or file.replace then
            file.index = index
            table.insert(self.downloadQueue, file)
            self.totalFiles = self.totalFiles + 1
        end
    end

    if self.totalFiles > 0 then
        self.isDownloading = true
        self:processQueue()
    else
        self:completeBatch()
    end
end

function DownloadManager:completeBatch()
    if self.hasCompleted then
        return
    end
    self.hasCompleted = true
    self.isDownloading = false
    if self.onCompleteCallback then
        self.onCompleteCallback(self.completedFiles > 0)
    end
    self:processNextBatch()
end

function DownloadManager:processQueue()
    while self.activeDownloads < self.maxConcurrentDownloads and #self.downloadQueue > 0 do
        local file = table.remove(self.downloadQueue, 1)
        self.activeDownloads = self.activeDownloads + 1
        self:downloadFile(file)
    end
end

function DownloadManager:downloadFile(file)
    local identifier = file.index or tostring(file.url)
    local linda = self.lanesHttp

    linda:send('request', {
        taskType = "download",
        url = file.url,
        filePath = file.path,
        identifier = identifier
    })

    self.downloadsInProgress[identifier] = file
end

function DownloadManager:queueFetches(fetchTable, onComplete)
    table.insert(self.pendingFetchBatches, {fetches = fetchTable, onComplete = onComplete})

    if not self.isFetching then
        self:processNextFetchBatch()
    end
end

function DownloadManager:processNextFetchBatch()
    if #self.pendingFetchBatches == 0 then
        self.isFetching = false
        return
    end

    local batch = table.remove(self.pendingFetchBatches, 1)
    self.currentFetchOnCompleteCallback = batch.onComplete

    self.isFetching = true
    self.hasCompletedFetch = false
    self.activeFetches = 0
    self.fetchQueue = {}
    self.fetchesInProgress = {}

    for _, fetch in ipairs(batch.fetches) do
        fetch.identifier = fetch.identifier or tostring(fetch.url)
        table.insert(self.fetchQueue, fetch)
    end

    if #self.fetchQueue > 0 then
        self:processFetchQueue()
    else
        self:completeFetchBatch() 
    end
end

function DownloadManager:processFetchQueue()
    while self.activeFetches < self.maxConcurrentDownloads and #self.fetchQueue > 0 do
        local fetch = table.remove(self.fetchQueue, 1)
        self.activeFetches = self.activeFetches + 1
        self:fetchData(fetch, function(decodedData)
            if fetch.callback then
                fetch.callback(decodedData)
            end

            self.activeFetches = self.activeFetches - 1

            if #self.fetchQueue > 0 then
                self:processFetchQueue()
            else
                if self.activeFetches == 0 then
                    self:completeFetchBatch()
                end
            end
        end)
    end
end

function DownloadManager:completeFetchBatch()
    if self.hasCompletedFetch then
        return
    end
    self.hasCompletedFetch = true
    if self.currentFetchOnCompleteCallback then
        self.currentFetchOnCompleteCallback()
    end
    self:processNextFetchBatch()
end

function DownloadManager:fetchData(fetch, onComplete)
    local identifier = fetch.identifier or tostring(fetch.url)
    local linda = self.lanesHttp

    linda:send('request', {
        taskType = "fetch",
        url = fetch.url,
        identifier = identifier
    })

    self.fetchesInProgress[identifier] = fetch

    fetch.onComplete = onComplete
end

function DownloadManager:updateDownloads()
    local linda = self.lanesHttp
    local downloadsToRemove = {}
    local fetchesToRemove = {}

    for identifier, file in pairs(self.downloadsInProgress) do
        local progressKey = 'progress_' .. identifier
        local completedKey = 'completed_' .. identifier
        local errorKey = 'error_' .. identifier

        local key, val = linda:receive(0, completedKey, errorKey, progressKey)
        if key and val then
            if key == completedKey then
                self.completedFiles = self.completedFiles + 1
                self.activeDownloads = self.activeDownloads - 1
                downloadsToRemove[identifier] = true
                self:processQueue()
            elseif key == errorKey then
                self.completedFiles = self.completedFiles + 1
                self.activeDownloads = self.activeDownloads - 1
                downloadsToRemove[identifier] = true
                self:processQueue()
            elseif key == progressKey then
                local fileProgress = 0
                if val.total > 0 then
                    fileProgress = (val.downloaded / val.total) * 100
                else
                    fileProgress = 0
                end

                local overallProgress = ((self.completedFiles + (val.downloaded / val.total)) / self.totalFiles) * 100

                if self.onProgressCallback then
                    self.onProgressCallback({
                        identifier = identifier,
                        downloaded = val.downloaded,
                        total = val.total,
                        fileProgress = fileProgress,
                        overallProgress = overallProgress,
                    }, file)
                end
            end
        end
    end

    for identifier, fetch in pairs(self.fetchesInProgress) do
        local completedKey = 'completed_' .. identifier
        local errorKey = 'error_' .. identifier

        local key, val = linda:receive(0, completedKey, errorKey)
        if key and val then
            if key == completedKey then
                local content = val.content
                local success, decoded = pcall(decodeJson, content)
                if success then
                    fetch.onComplete(decoded)
                else
                    print("Failed to decode JSON:", decoded)
                end
                fetchesToRemove[identifier] = true
            elseif key == errorKey then
                print("Error fetching data:", val.error)
                fetchesToRemove[identifier] = true
            end
        end
    end

    for identifier in pairs(downloadsToRemove) do
        self.downloadsInProgress[identifier] = nil
    end

    for identifier in pairs(fetchesToRemove) do
        self.fetchesInProgress[identifier] = nil
    end

    if self.activeDownloads == 0 and #self.downloadQueue == 0 and not self.hasCompleted then
        self:completeBatch()
    end

    if self.activeFetches == 0 and #self.fetchQueue == 0 and not self.isFetching then
        self.isFetching = false
    end
end

local downloadManager = DownloadManager:new(defaultMaxConcurrentDownloads)

return downloadManager -- Return the table