script_name('libraries')
script_author("akacross")
script_version("0.4.13")
script_url("https://akacross.net/")

-- Paths
local workingDir = getWorkingDirectory()
local configDir = workingDir .. '\\config\\'
local cfgFile = configDir .. 'libraries.json'

-- URLs
local url = "https://raw.githubusercontent.com/akacross/libraries/main/"

local libs = {firstRun = true}

local folders = {
	"\\lib",
	"\\lib\\windows",
	"\\lib\\game",
	"\\lib\\samp",
	"\\lib\\samp\\events",
	"\\lib\\mimgui",
	"\\lib\\extensions-lite",
	"\\lib\\extensions-lite\\core",
	"\\lib\\ssl",
	"\\lib\\socket",
	"\\lib\\mime",
	"\\lib\\SAMemory",
	"\\lib\\SAMemory\\game",
	"\\lib\\copas",
	"\\lib\\cjson",
	"\\lib\\lub",
	"\\lib\\md5",
	"\\lib\\xml",
	"\\resource",
	"\\resource\\fonts"
}

local files = {
	"lib/ssl.dll", "lib/ssl.lua", "lib/ssl/https.lua", "lib/socket.lua", "lib/socket/core.dll", "lib/socket/ftp.lua", "lib/socket/headers.lua", "lib/socket/http.lua", "lib/socket/smtp.lua", "lib/socket/tp.lua", "lib/socket/url.lua", "lib/ltn12.lua", "lib/mime.lua", "lib/mime/core.dll",
	"lib/bitex.lua", 
	"lib/encoding.lua", 
	"lib/iconv.dll", 
	"lib/matrix3x3.lua", 
	"lib/moonloader.lua",
	"lib/sampfuncs.lua",
	"lib/vector3d.lua",
	"lib/vkeys.lua",
	"lib/windows/init.lua", "lib/windows/message.lua",
	"lib/game/globals.lua", "lib/game/keys.lua", "lib/game/models.lua", "lib/game/weapons.lua",
	"lib/samp/events.lua", "lib/samp/raknet.lua", "lib/samp/synchronization.lua", "lib/samp/events/bitstream_io.lua", "lib/samp/events/core.lua", "lib/samp/events/extra_types.lua", "lib/samp/events/handlers.lua", "lib/samp/events/utils.lua", 
	"lib/mimgui/cdefs.lua", "lib/mimgui/cimguidx9.dll", "lib/mimgui/dx9.lua", "lib/mimgui/imgui.lua", "lib/mimgui/init.lua", "lib/mimgui_addons.lua", "lib/mimgui_piemenu.lua",
	"lib/extensions-lite/bit.lua", "lib/extensions-lite/init.lua", "lib/extensions-lite/string.lua", "lib/extensions-lite/table.lua", "lib/extensions-lite/core/util.lua",
	"lib/imgui.lua", "lib/MoonImGui.dll", "lib/imgui_addons.lua", "lib/imgui_piemenu.lua",
	"lib/fa-icons.lua", "lib/fAwesome5.lua", "lib/tabler_icons.lua", "lib/fAwesome6.lua",
	"lib/lfs.dll",
	"lib/hooks.lua",
	"lib/rkeys.lua",
	"lib/names.lua",
	"lib/SAMemory/init.lua", "lib/SAMemory/metatype.lua", "lib/SAMemory/shared.lua", "lib/SAMemory/game/AnimBlendFrameData.lua", "lib/SAMemory/game/C2dEffect.lua", "lib/SAMemory/game/CAEAudioEntity.lua", "lib/SAMemory/game/CAEPedAudioEntity.lua", "lib/SAMemory/game/CAEPedSpeechAudioEntity.lua", "lib/SAMemory/game/CAEPoliceScannerAudioEntity.lua", "lib/SAMemory/game/CAESound.lua", "lib/SAMemory/game/CAETwinLoopSoundEntity.lua",
	"lib/SAMemory/game/CAEVehicleAudioEntity.lua", "lib/SAMemory/game/CAEWeaponAudioEntity.lua", "lib/SAMemory/game/CAttractorScanner.lua", "lib/SAMemory/game/CAutomobile.lua", "lib/SAMemory/game/CAutoPilot.lua", "lib/SAMemory/game/CBike.lua", "lib/SAMemory/game/CBmx.lua", "lib/SAMemory/game/CBoat.lua", "lib/SAMemory/game/CBouncingPanel.lua", "lib/SAMemory/game/CCam.lua", "lib/SAMemory/game/CCamera.lua", "lib/SAMemory/game/CCamPathSplines.lua", 
	"lib/SAMemory/game/CColBox.lua", "lib/SAMemory/game/CColDisk.lua", "lib/SAMemory/game/CColLine.lua", "lib/SAMemory/game/CCollisionData.lua", "lib/SAMemory/game/CColModel.lua", "lib/SAMemory/game/CColourSet.lua", "lib/SAMemory/game/CColPoint.lua", "lib/SAMemory/game/CColSphere.lua", "lib/SAMemory/game/CColTriangle.lua", "lib/SAMemory/game/CColTrianglePlane.lua", "lib/SAMemory/game/CCopPed.lua", "lib/SAMemory/game/CCrimeBeingQd.lua",
	"lib/SAMemory/game/CCutsceneObject.lua", "lib/SAMemory/game/CDamageManager.lua", "lib/SAMemory/game/CDoor.lua", "lib/SAMemory/game/CDummy.lua", "lib/SAMemory/game/CEntity.lua", "lib/SAMemory/game/CEntityScanner.lua", "lib/SAMemory/game/CEventGroup.lua", "lib/SAMemory/game/CEventHandler.lua", "lib/SAMemory/game/CEventScanner.lua", "lib/SAMemory/game/CFire.lua", "lib/SAMemory/game/CHeli.lua", "lib/SAMemory/game/CMatrixLink.lua", "lib/SAMemory/game/CObject.lua",
	"lib/SAMemory/game/CObjectInfo.lua", "lib/SAMemory/game/CompressedVector.lua", "lib/SAMemory/game/CPed.lua", "lib/SAMemory/game/CPedAcquaintance.lua", "lib/SAMemory/game/CPedClothesDesc.lua", "lib/SAMemory/game/CPedIK.lua", "lib/SAMemory/game/CPedIntelligence.lua", "lib/SAMemory/game/CPhysical.lua", "lib/SAMemory/game/CPlaceable.lua", "lib/SAMemory/game/CPlane.lua", "lib/SAMemory/game/CPlayerData.lua", "lib/SAMemory/game/CPlayerInfo.lua", 
	"lib/SAMemory/game/CPlayerPed.lua", "lib/SAMemory/game/CPool.lua", "lib/SAMemory/game/CQueuedMode.lua", "lib/SAMemory/game/CRealTimeShadow.lua", "lib/SAMemory/game/CReference.lua", "lib/SAMemory/game/CReferences.lua", "lib/SAMemory/game/CRideAnimData.lua", "lib/SAMemory/game/CShadowCamera.lua", "lib/SAMemory/game/CSimpleTransform.lua", "lib/SAMemory/game/CStoredCollPoly.lua", "lib/SAMemory/game/CTask.lua", "lib/SAMemory/game/CTaskManager.lua", 
	"lib/SAMemory/game/CTaskTimer.lua", "lib/SAMemory/game/CTrain.lua", "lib/SAMemory/game/CTransmission.lua", "lib/SAMemory/game/CVehicle.lua", "lib/SAMemory/game/CWanted.lua", "lib/SAMemory/game/CWeapon.lua", "lib/SAMemory/game/CWeaponEffects.lua", "lib/SAMemory/game/CWeaponInfo.lua", "lib/SAMemory/game/eCamMode.lua", "lib/SAMemory/game/ePedState.lua", "lib/SAMemory/game/ePedType.lua", "lib/SAMemory/game/eVehicleHandlingFlags.lua", 
	"lib/SAMemory/game/eVehicleHandlingModelFlags.lua", "lib/SAMemory/game/eWeaponType.lua", "lib/SAMemory/game/FxSystem_c.lua", "lib/SAMemory/game/matrix.lua", "lib/SAMemory/game/quaternion.lua", "lib/SAMemory/game/RenderWare.lua", "lib/SAMemory/game/tBoatHandlingData.lua", "lib/SAMemory/game/tFlyingHandlingData.lua", "lib/SAMemory/game/tHandlingData.lua", "lib/SAMemory/game/tTransmissionGear.lua", "lib/SAMemory/game/vector2d.lua", "lib/SAMemory/game/vector3d.lua",
	"lib/copas.lua", "lib/copas/http.lua",
	"lib/cjson/util.lua",
	"lib/lub/Autoload.lua", "lib/lub/Dir.lua", "lib/lub/init.lua", "lib/lub/Param.lua", "lib/lub/Template.lua",
	"lib/md5/core.dll",
	"lib/xml/core.dll", "lib/xml/init.lua", "lib/xml/Parser.lua",
	"lib/base64.dll",
	"lib/cjson.dll",
	"lib/effil.lua", "lib/libeffil.dll",
	"lib/md5.lua",
	"lib/requests.lua",
	"resource/fonts/fa-solid-900.ttf"
}

function main()
	createDirectory(configDir)
	if doesFileExist(cfgFile) then
		local config, err = loadConfig(cfgFile)
        if not config then
            print("Error loading config: " .. err)
        else
			libs = config
        end
	end

	repeat wait(0) until isSampAvailable()

	checkLib()
	wait(-1)
end

function checkLib()
	for _, folder in pairs(folders) do createDirectory(workingDir .. folder) end

	local downloads = {}
	for k, v in pairs(files) do table.insert(downloads, {url = url .. v, path = workingDir .. '\\' .. v, replace = libs.firstRun}) end
    downloadFiles(downloads, function(result)
        if result then
			libs.firstRun = false

			local success, err = saveConfig(cfgFile, libs)
            if not success then print("Error saving config: " .. err) end

            sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} All files downloaded successfully! Reinitializing all scripts now!", thisScript().name:gsub("^%l", string.upper), string), -1)
            reloadScripts()
		end
    end)
end

function loadConfig(filePath)
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

function saveConfig(filePath, config)
    local file = io.open(filePath, "w")
    if not file then
        return false, "Could not save file."
    end
    file:write(encodeJson(config, true))
    file:close()
    return true
end

function downloadFiles(table, onCompleteCallback)
    local downloadsInProgress = 0
    local downloadsStarted = false
    local callbackCalled = false

    local function download_handler(id, status, p1, p2)
        if status == 6 then
            downloadsInProgress = downloadsInProgress - 1
        end

        if downloadsInProgress == 0 and onCompleteCallback and not callbackCalled then
            callbackCalled = true
            onCompleteCallback(downloadsStarted)
        end
    end

    for _, file in ipairs(table) do
        if not doesFileExist(file.path) or file.replace then
            downloadsInProgress = downloadsInProgress + 1
            downloadsStarted = true
            downloadUrlToFile(file.url, file.path, download_handler)
        end
    end

    if not downloadsStarted and onCompleteCallback and not callbackCalled then
        callbackCalled = true
        onCompleteCallback(downloadsStarted)
    end
end
