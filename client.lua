RegisterNetEvent('fq:pickedCharacter')

local CFG = exports['fq_essentials']:getCFG()
local mCFG = CFG.menu
local gCFG = CFG.gangs
local msgCFG = CFG.msg.pl

local gangIndex = 1
local modelIndex = 1
local peds = {}
local isOpen = false
local isReady = false
local sp = {}
local sv_g = nil
local ESXs = exports['fq_callbacks']:getServerObject()
local showAlert = true

local guns = {
	"WEAPON_KNIFE", "WEAPON_HAMMER", "WEAPON_BAT",  
	"WEAPON_CROWBAR", "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50",  
	"WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG", "WEAPON_ASSAULTRIFLE",  
	"WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN",  
	"WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_SNIPERRIFLE",  
	"WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_GRENADELAUNCHER_SMOKE",  
	"WEAPON_SNSPISTOL", "WEAPON_SPECIALCARBINE",  
	"WEAPON_HEAVYPISTOL", "WEAPON_VINTAGEPISTOL", "WEAPON_MARKSMANRIFLE",  
	"WEAPON_HEAVYSHOTGUN", "WEAPON_HATCHET", "WEAPON_COMBATPDW",  
	"WEAPON_MARKSMANPISTOL", "WEAPON_MACHETE", "WEAPON_MACHINEPISTOL",  
	"WEAPON_SWITCHBLADE", "WEAPON_REVOLVER", "WEAPON_COMPACTRIFLE", "WEAPON_DBSHOTGUN",  
	"WEAPON_AUTOSHOTGUN", "WEAPON_BATTLEAXE", "WEAPON_MINISMG", "WEAPON_WRENCH"  
}

RegisterNetEvent('fq:onAuth')
AddEventHandler('fq:onAuth', function()
    msgCFG = CFG.msg[exports['fq_login']:getLang()]
end)

local function init()
	if not isReady then
		local playerSpawnPoint = {
			x = mCFG.player.position.x, y = mCFG.player.position.y, z = mCFG.player.position.z,
			heading = mCFG.player.heading,
			model = 'mp_m_freemode_01',
			skipFade = true
		}
		
		-- local mainSpawnPoint = {
		-- 	['x']=-15.302675247192,['y']=-1452.7022705078,['z']=30.528675079346,
		-- 	heading = mCFG.player.heading,
		-- 	model = 'mp_m_freemode_01'
		-- }
		
		sp.player = exports.spawnmanager:addSpawnPoint(playerSpawnPoint)
		-- sp.mainSpawn = exports.spawnmanager:addSpawnPoint(mainSpawnPoint)
		
		isReady = true
	end
end

local function setPedOptions(ped, k)
	-- local ran = GetRandomIntInRange(1, #guns)

	-- GiveWeaponToPed(ped, GetHashKey(guns[ran]), 256, false, true)
	-- SetCurrentPedWeapon(ped, GetHashKey(guns[ran]), true)
	
	SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
end

local function wearPed(ped, k)
	local f1, f2, f3, f4 = k.face[1], k.face[2], k.face[3], k.face[4]

	SetPedHeadBlendData(ped, f1, f2, 0, f1, f2, 0, f3, f4, 0.0, false)

	for o, n in pairs(k.components) do
		SetPedComponentVariation(ped, o, n[1], n[2], 2)
	end
end

local function swapPeds(direction)
	local pedToTP = peds[gangIndex][modelIndex]
	local pos = mCFG.ped.position
	-- local modelNum = 4
	local modelNum = 5

	modelIndex = modelIndex + direction

	if modelIndex > modelNum then
		modelIndex = 1
	end
	if modelIndex < 1 then
		modelIndex = modelNum
	end

	SetEntityCoordsNoOffset(pedToTP, pos.x + 10.0, pos.y, pos.z, false, false, false)
	SetEntityCoordsNoOffset(peds[gangIndex][modelIndex], pos.x, pos.y, pos.z, false, false, false)
end

local function swapGang(gangId)
	local pedToTP = peds[gangIndex][modelIndex]
	local pos = mCFG.ped.position

	gangIndex = gangId
	modelIndex = 1
	
	SetEntityCoordsNoOffset(pedToTP, pos.x + 10.0, pos.y, pos.z, false, false, false)
	SetEntityCoordsNoOffset(peds[gangIndex][modelIndex], pos.x, pos.y, pos.z, false, false, false)
end

local function getMax(tab)
	local max = 0
	for i, v in ipairs(tab) do
		if v > max then
			max = v
		end
	end
	return max
end

local function getMin(tab)
	local min = 99999999
	for i, v in ipairs(tab) do
		if v < min then
			min = v
		end
	end
	return min
end

AddEventHandler('onClientResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end

	init()

	--                                    SHOWING MENU BEFORE LOGIN PANEL
	-- if not isOpen then
	-- 	TriggerEvent('fq:showMenu')
	-- end

	exports.spawnmanager:setAutoSpawn(true)
	exports.spawnmanager:setAutoSpawnCallback(function()
		local mainSpawnPoint = {
			['x']=-15.302675247192,['y']=-1452.7022705078,['z']=30.528675079346,
			heading = mCFG.player.heading,
		}
		if sp.mainSpawn then 
			exports.spawnmanager:spawnPlayer(sp.mainSpawn, function()
				TriggerEvent('fq:giveWeaponKit')
			end)
			return
		end
		-- cant do it by spawn point adding poniewaz addspawnpoint function sprawdza czu model jest ustawiony
		exports.spawnmanager:spawnPlayer(mainSpawnPoint)
	end)
end)

AddEventHandler('onClientMapStart', function()
	
end)
  

RegisterNetEvent('fq:showMenu')
AddEventHandler('fq:showMenu', function()
	showAlert = true
	TriggerEvent('hideChat', true)
	SetNuiFocus(true, true)
	
	exports.spawnmanager:spawnPlayer(sp.player, function()
		exports.spawnmanager:freezePlayer(PlayerId(), true)

		RequestModel('mp_m_freemode_01')
		RequestModel('mp_f_freemode_01')
		
		while not HasModelLoaded('mp_f_freemode_01') or not HasModelLoaded('mp_m_freemode_01') do
			Wait(5)
		end
		
		local pos = mCFG.player.position
		for i, v in ipairs(gCFG) do
			peds[i] = {}
			for j, k in ipairs(v.models) do
				local ped = CreatePed(4, GetHashKey(k.model), pos.x + 10.0, pos.y, pos.z, mCFG.ped.heading, false, false)
				setPedOptions(ped)
				wearPed(ped, k)
				peds[i][j] = ped
			end
		end

		pos = mCFG.ped.position
		SetEntityCoordsNoOffset(peds[1][1], pos.x, pos.y, pos.z, false, false, false)

		SetModelAsNoLongerNeeded('mp_f_freemode_01')
		SetModelAsNoLongerNeeded('mp_m_freemode_01')
		TriggerEvent('fq:changeMenuState', true)
		Wait(200)
		showAlert = false
		SetNuiFocus(true, true)
	end)

	local pos = mCFG.cam.position
	local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, 0, 0, mCFG.player.heading, 50.0)
	
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, true, false)
	
	SetCamAffectsAiming(cam, false)
	isOpen = true
end)

RegisterNetEvent('fq:closeMenu')
AddEventHandler('fq:closeMenu', function()
	exports.spawnmanager:freezePlayer(PlayerId(), false)
	RenderScriptCams(false, true, 1000, true, false)
	
	for i, v in ipairs(peds) do
		for j, k in ipairs(v) do 
			DeletePed(k)
		end
	end

	TriggerEvent('hideChat', false)
	isOpen = false
end)

RegisterNetEvent('fq:receiveZonesData')
AddEventHandler('fq:receiveZonesData', function(svG)
    sv_g = svG
end)

RegisterNetEvent('fq:changeMenuState')
AddEventHandler('fq:changeMenuState', function(state)
	SendNUIMessage({
		type = 'ON_STATE',
		display = state
	})

	if not state then 
		TriggerEvent('fq:closeMenu')
		SetNuiFocus(false, false)
	end
end)

RegisterNetEvent('fq:updateUI_info')
AddEventHandler('fq:updateUI_info', function(values)
	SendNUIMessage({
		type = 'ON_UPDATE_INFO',
		info = values
	})
end)

RegisterNetEvent('fq:sendUINotification')
AddEventHandler('fq:sendUINotification', function(text)
	SendNUIMessage({
		type = 'ON_NOTOFICATION',
		msg = text
	})
end)

RegisterNetEvent('fq:sendCurrentModelID')
AddEventHandler('fq:sendCurrentModelID', function(_id)
	SendNUIMessage({
		type = 'ON_MODEL_NEXT',
		id = _id
	})
end)

RegisterNUICallback('menuResult', function(data, cb)
	if data.type == "ON_STATE" then
		if data.display == false then
			-- --
		end
	elseif data.type == "ON_MODEL_CHANGE" then
		if data.direction == 1 or data.direction == -1 then
			swapPeds(data.direction)
			TriggerEvent('fq:sendCurrentModelID', modelIndex)
		end
	elseif data.type == "ON_GANG_CHANGE" then
		if data.id >= 1 and data.id <= 4 then -- gang id range
			swapGang(data.id)
			TriggerEvent('fq:sendCurrentModelID', modelIndex)
		end
	elseif data.type == "ON_TRY_JOIN" then
		ESXs.TriggerServerCallback('fq:updateZones', function(Ginfo, canPick)
			sv_g = Ginfo

			if modelIndex == 5 then
				if not canPick then
					TriggerEvent('fq:sendUINotification', msgCFG.c.menu_need_vip)
					return
				end
			end

			local min = getMin({#sv_g.list[1], #sv_g.list[2], #sv_g.list[3], #sv_g.list[4]})

			if (#sv_g.list[data.gangId] + 1 <= min + 1) then
				local info = gCFG[gangIndex].models[modelIndex]
				local pos = gCFG[data.gangId].spawnPoint

				local mainSpawnPoint = {
					['x']=pos.x,['y']=pos.y,['z']=pos.z,
					model = info.model,
					heading = pos.h,
					skipModelAfterDeath = true
				}
				
				sp.mainSpawn = exports.spawnmanager:addSpawnPoint(mainSpawnPoint, true)

				setModel(info.model)
				exports.spawnmanager:spawnPlayer(sp.mainSpawn, function()
					wearPed(GetPlayerPed(-1), info)
					TriggerEvent('fq:giveWeaponKit')
				end)

				TriggerEvent('fq:pickedCharacter', gangIndex, modelIndex)
				TriggerEvent('fq:changeMenuState', false)

				gangIndex = 1
				modelIndex = 1
			else
				TriggerEvent('fq:sendUINotification', msgCFG.c.menu_keep_balance)
			end
		end)
	end
end)

function setModel(model)
	RequestModel(model)
    
    while not HasModelLoaded(model) do
        Wait(5)
    end
    
    SetPlayerModel(PlayerId(), GetHashKey(model))
    SetModelAsNoLongerNeeded(model)
end

RegisterCommand('test2', function(source, args)
	
end)

-- Citizen.CreateThread(function() 
-- 	AddTextEntry("FACES_WARNH2", "Loading models...")
-- 	AddTextEntry("QM_NO_0", "Stand by")
-- 	AddTextEntry("QM_NO_3", "*.*")

-- 	while true do 
-- 		Citizen.Wait(1)
-- 		if showAlert then
-- 			DrawFrontendAlert("FACES_WARNH2", "QM_NO_0", 134217728, 0,
-- 			"QM_NO_3", 0, -1, false, "", "", true, 10)
-- 		end
-- 	end
-- end)

Citizen.CreateThread(function() 

	while true do 
		Citizen.Wait(250)
		if isOpen then
			TriggerEvent('fq:updateUI_info', {
				gangs = {#sv_g.list[1], #sv_g.list[2], #sv_g.list[3], #sv_g.list[4]}
			})
		end
	end
end)

Citizen.CreateThread(function()
	local pos = mCFG.ped.position
	while true do
		Citizen.Wait(1)
		if isOpen then
			DrawLightWithRange(pos.x ,pos.y, pos.z + 2.0, 255,255,255, 5.0, 1.0)
			HideHudAndRadarThisFrame()
			-- if IsDisabledControlJustPressed(0, 172) then -- up 
			-- 	swapGang(-1)
			-- end
			-- if IsDisabledControlJustPressed(0, 173) then -- down 
			-- 	swapGang(1)
			-- end
			-- if IsDisabledControlJustPressed(0, 174) then -- left 
			-- 	swapPeds(-1)             
			-- end
			-- if IsDisabledControlJustPressed(0, 175) then -- right
			-- 	swapPeds(1)
			-- end   
		end
	end
end)