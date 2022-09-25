script_name('Libraries')
script_author('akacross')
script_url("https://akacross.net")

local script_version = 0.2
local script_version_text = '0.2'

local ssl_res, https = pcall(require, 'ssl.https')
local path = getWorkingDirectory() .. '\\config\\' 
local cfg = path .. 'libraries.ini'
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/akacross/libraries/main/libraries.lua"
local update_url = "https://raw.githubusercontent.com/akacross/libraries/main/libraries.txt"

local libs = {
	autosave = true,
	autoupdate = true,
	deletelibfiles = false
}

local folders = {
	"lib", 
	"lib/windows", 
	"lib/game", 
	"lib/samp", 
	"lib/samp/events", 
	"lib/mimgui", 
	"lib/extensions-lite", 
	"lib/extensions-lite/core", 
	"lib/ssl", 
	"lib/socket", 
	"lib/mime", 
	"lib/SAMemory", 
	"lib/SAMemory/game", 
	"lib/copas", 
	"resource", 
	"resource/fonts"
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
	"lib/samp/events.lua", "lib/samp/raknet.lua", "lib/samp/synchronization.lua", "lib/samp/events/bitstream_io.lua", "lib/samp/events/core.lua", "lib/samp/events/extra_types.lua", "lib/samp//events/handlers.lua", "lib/samp/events/utils.lua", 
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
	"resource/fonts/fa-solid-900.ttf"
}

local libscheck = true
local update = false
local runonce = true
local ip = "127.0.0.1"
local port = 7777

function main()
	if not doesDirectoryExist(path) then createDirectory(path) end
	if doesFileExist(cfg) then loadIni() else blankIni() end
	while not isSampAvailable() do wait(100) end
	
	ip, port = sampGetCurrentServerAddress() 
	
	checkLib()
	
	if libs.autoupdate then
		update_script()
	end
	
	wait(-1)
end

function checkLib()
	if not libs.deletelibfiles then
		for _, s in pairs(script.list()) do
			if s ~= script.this then
				s:unload()
			end
		end
		for k, v in pairs(files) do
			if doesFileExist(getWorkingDirectory().."/"..v) then
				if runonce then
					sampConnectToServer("127.0.0.1", 7777)
					sampSetGamestate(0)
					runonce = false
				end
				os.remove(getWorkingDirectory().."/"..v)
				sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} Deleting File: %s", script.this.name, v), -1)
				wait(100)
			end
		end
		libs.deletelibfiles = true
		saveIni()
	end
	
	for k, v in pairs(folders) do 
		if not doesDirectoryExist(getWorkingDirectory().."/"..v) then 
			createDirectory(getWorkingDirectory().."/"..v) 
			sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} Creating Folder: %s", script.this.name, v), -1)
			wait(100)
		end 
	end
	for k, v in pairs(files) do
		if not doesFileExist(getWorkingDirectory().."/"..v) then
			if runonce then
				sampConnectToServer("127.0.0.1", 7777)
				sampSetGamestate(0)
				runonce = false
			end
			downloadUrlToFile("https://raw.githubusercontent.com/akacross/libraries/main/" .. v, getWorkingDirectory().."/"..v)
			sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} Downloading File: %s", script.this.name, v), -1)
			wait(100)
			libscheck = false
		end
	end
	if not libscheck then
		sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} Reloading scripts and reconnecting to the server in 20 seconds", script.this.name), -1)
		wait(20000)
		sampSetGamestate(1)
		sampConnectToServer(ip, port)
		reloadScripts()
	end
end

function update_script()
	if ssl_res then
		update_text = https.request(update_url)
		if update_text ~= nil then
			update_version = update_text:match("version: (.+)")
			if tonumber(update_version) > script_version then
				sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} New version found! The update is in progress..", script.this.name), -1)
				downloadUrlToFile(script_url, script_path, function(id, status)
					if status == 6 then
						sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} The update was successful!", script.this.name), -1)
						lua_thread.create(function() 
							sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} Reloading the script in 20 seconds", script.this.name), -1)
							wait(20000) 
							thisScript():reload()
						end)
					end
				end)
			end
		end
	end
end

function blankIni()
	saveIni()
	loadIni()
end

function loadIni()
	local f = io.open(cfg, "r")
	if f then
		libs = decodeJson(f:read("*all"))
		f:close()
	end
end

function saveIni()
	if type(libs) == "table" then
		local f = io.open(cfg, "w")
		f:close()
		if f then
			f = io.open(cfg, "r+")
			f:write(encodeJson(libs))
			f:close()
		end
	end
end
