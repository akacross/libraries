local configs = {}
configs._VERSION = '0.1.0'
configs.__index = configs

local function isSparseArray(tbl)
    local count = 0
    for k, v in pairs(tbl) do
        if type(k) == "number" then
            count = count + 1
        end
    end
    return count ~= #tbl
end

local function checkForIssues(tbl, path)
    path = path or ""
    for k, v in pairs(tbl) do
        local currentPath = path .. "." .. k
        if v == nil then
            print("Nil value found at key: " .. currentPath)
            return false, "Nil value found at key: " .. currentPath
        elseif type(v) == "table" then
            if isSparseArray(v) then
                print("Sparse array found at key: " .. currentPath)
                return false, "Sparse array found at key: " .. currentPath
            end
            local success, err = checkForIssues(v, currentPath)
            if not success then
                return false, err
            end
        end
    end
    return true
end

function configs.handleConfigFile(path, defaults, configVar, ignoreKeys)
    ignoreKeys = ignoreKeys or {}
    if doesFileExist(path) then
        local config, err = configs.loadConfig(path)
        if not config then
            print("Error loading config from " .. path .. ": " .. err)

            local newpath = path:gsub("%.[^%.]+$", ".bak")
            local success, err2 = os.rename(path, newpath)
            if not success then
                print("Error renaming config: " .. err2)
                os.remove(path)
            end
            return configs.handleConfigFile(path, defaults, configVar)
        else
            local result = configs.ensureDefaults(config, defaults, false, ignoreKeys)
            if result then
                local success, err2 = configs.saveConfig(path, config)
                if not success then
                    return false, nil, "Error saving config: " .. err2
                end
            end
            return true, config, nil
        end
    else
        local result = configs.ensureDefaults(configVar, defaults, true)
        if result then
            local success, err = configs.saveConfig(path, configVar)
            if not success then
                return false, nil, "Error saving config: " .. err
            end
        end
    end
    return true, configVar, nil
end

function configs.ensureDefaults(config, defaults, reset, ignoreKeys)
    ignoreKeys = ignoreKeys or {}
    local status = false

    local function isIgnored(key, path)
        local fullPath = table.concat(path, ".") .. "." .. key
        for _, ignoreKey in ipairs(ignoreKeys) do
            if type(ignoreKey) == "table" then
                local ignorePath = table.concat(ignoreKey, ".")
                if fullPath == ignorePath then
                    return true
                end
            elseif key == ignoreKey then
                return true
            end
        end
        return false
    end

    local function cleanupConfig(conf, def, path)
        local localStatus = false
        for k, v in pairs(conf) do
            local newPath = {table.unpack(path)}
            table.insert(newPath, k)
            if not isIgnored(k, path) then
                if def[k] == nil then
                    conf[k] = nil
                    localStatus = true
                elseif type(conf[k]) == "table" and type(def[k]) == "table" then
                    localStatus = cleanupConfig(conf[k], def[k], newPath) or localStatus
                end
            end
        end
        return localStatus
    end

    local function copyDefaults(t, d, p)
        for k, v in pairs(d) do
            local newPath = {table.unpack(p)}
            table.insert(newPath, k)
            if not isIgnored(k, p) then
                if type(v) == "table" then
                    if type(t[k]) ~= "table" then
                        t[k] = {}
                        status = true
                    end
                    copyDefaults(t[k], v, newPath)
                elseif t[k] == nil or (reset and not isIgnored(k, p)) then
                    t[k] = v
                    status = true
                end
            end
        end
    end

    copyDefaults(config, defaults, {})
    status = cleanupConfig(config, defaults, {}) or status

    return status
end

function configs.loadConfig(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return nil, "Could not open file."
    end

    local content = file:read("*a")
    file:close()

    if not content or content == "" then
        return nil, "Config file is empty."
    end

    local success, decoded = pcall(decodeJson, content)
    if success then
        if next(decoded) == nil then
            return nil, "JSON format is empty."
        else
            return decoded, nil
        end
    else
        return nil, "Failed to decode JSON: " .. decoded
    end
end

function configs.saveConfig(filePath, config)
    local success, err = checkForIssues(config)
    if not success then
        return false, err
    end

    local file = io.open(filePath, "w")
    if not file then
        return false, "Could not save file."
    end
    file:write(encodeJson(config, true))
    file:close()
    return true
end

function configs.saveConfigWithErrorHandling(path, config)
    local success, err = configs.saveConfig(path, config)
    if not success then
        print("Error saving config to " .. path .. ": " .. err)
    end
    return success
end

function configs.deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = configs.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

return configs
