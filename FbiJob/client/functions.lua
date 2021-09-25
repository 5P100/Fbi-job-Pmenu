ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- No function
Citizen.CreateThread(function()
    local hash = GetHashKey("a_f_y_business_02")
    while not HasModelLoaded(hash) do
    	RequestModel(hash)
    	Wait(20)        
    end                                                    
    ped = CreatePed("PED_TYPE_CIVMALE", "a_f_y_business_02", 116.97, -747.33, 44.76, 114.72, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
end)

-- Joueurs & Autres
Notification = function(msg)
    SetNotificationTextEntry('STRING') 
    AddTextComponentSubstringPlayerName(msg) 
    DrawNotification(false, true) 
end

Advancednotif = function(title, subject, msg, icon, iconType)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    SetNotificationMessage(icon, icon, false, iconType, title, subject)
    DrawNotification(false, false)
end

function PlayAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 1, 1, false, false, false)
    RemoveAnimDict(animDict)
end

function TpAscenceurs(coords)
	local playerPed = PlayerPedId()
	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(playerPed, coords, function()
			DoScreenFadeIn(800)
		end)
	end)
end

setCameraCreator = function(camType)
    if camType == 1 then
        cam1 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam1, true)
        PointCamAtEntity(cam1, PlayerPedId(), 0, 0, 0, 1)
        SetCamParams(cam1, 115.6, -764.67, 242.09, 20.0, 0.0, 84.65463, 42.2442, 0, 1, 1, 2)
        SetCamFov(cam1, 82.0)
        RenderScriptCams(1, 0, 0, 1, 1)
    end
end

destroyCameraCreator = function(destroyCam)
    if destroyCam == 1 then
        DestroyCam(cam1, false)
        RenderScriptCams(false, true, 1, false, false)
    end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		ESX.ShowNotification(_U('unrestrained_timer'))
		TriggerEvent('esx_fbi_job:unrestrain')
		handcuffTimer.active = false
	end)
end

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function SetFBIOutfit()
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			uniformObject = Config.Uniforms.Agent.male
		else
			uniformObject = Config.Uniforms.Agent.female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
		else
			ESX.ShowNotification(_U('no_outfit'))
		end
	end)
end

function GetEquipement()
	local playerPed = GetPlayerPed(-1)
	for k,v in pairs(Config.Weapons) do
		GiveWeaponToPed(playerPed, GetHashKey(v), 255, 1, 0)
	end
end

function RemovePlayerWeapons()
	local playerPed = GetPlayerPed(-1)
	for k,v in pairs(Config.Weapons) do
		RemoveWeaponFromPed(playerPed, GetHashKey(v))
	end
end

function SetBulletProof()
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			uniformObject = Config.Uniforms.bullet_wear.male
		else
			uniformObject = Config.Uniforms.bullet_wear.female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
		else
			ESX.ShowNotification(_U('no_outfit'))
		end
		Citizen.Wait(interval)
		SetPedArmour(playerPed, 100)
	end)
end

function ShowLoadingMessage(text, spinnerType, timeMs)
	Citizen.CreateThread(function()
		BeginTextCommandBusyspinnerOn("STRING")
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandBusyspinnerOn(spinnerType)
		Wait(timeMs)
		RemoveLoadingPrompt()
	end)
end

-- Vehicules
function spawnCar(car)
	local playerPed = PlayerPedId()
	local car = GetHashKey(car)
	local spawnPos = vector3(100.12, -728.37, 32.45)
	local headingPos = 339.88

	RequestModel(car)
	while not HasModelLoaded(car) do
		RequestModel(car)
		Citizen.Wait(50)
	end

	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
	local vehicle = CreateVehicle(car, spawnPos, headingPos, true, false)

	SetEntityAsNoLongerNeeded(vehicle)
	SetVehicleNumberPlateText(vehicle, "188IBF")

	SetEntityAsMissionEntity(vehicle, 1, 1)
	SetVehicleDirtLevel(vehicle, 0.0)
	
	ShowLoadingMessage("Sortie de véhicule de fonction.", 2, 2000)
	Wait(350)
	TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
	CloseMenu(force)
end	

function ImpoundVehicle(vehicle)
	--local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
	ESX.Game.DeleteVehicle(vehicle)
	ESX.ShowNotification(_U('impound_successful'))
	currentTask.busy = false
end


function OpenVehicleInfosMenu(vehicleData)
	ESX.TriggerServerCallback('esx_fbi_job:getVehicleInfos', function(retrivedInfo)
		local elements = {{label = _U('plate', retrivedInfo.plate)}}

		if not retrivedInfo.owner then
			table.insert(elements, {label = _U('owner_unknown')})
		else
			table.insert(elements, {label = _U('owner', retrivedInfo.owner)})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
			title = _U('vehicle_info'),
			align = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, vehicleData.plate)
end

function StoreNearbyVehicle(playerCoords)
	local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}

	if #vehicles > 0 then
		for k,v in ipairs(vehicles) do

			-- Make sure the vehicle we're saving is empty, or else it wont be deleted
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		ESX.ShowNotification(_U('garage_store_nearby'))
		return
	end

	ESX.TriggerServerCallback('esx_fbi_job:storeNearbyVehicle', function(storeSuccess, foundNum)
		if storeSuccess then
			local vehicleId = vehiclePlates[foundNum]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true

			Citizen.CreateThread(function()
				BeginTextCommandBusyspinnerOn('STRING')
				AddTextComponentSubstringPlayerName(_U('garage_storing'))
				EndTextCommandBusyspinnerOn(4)

				while IsBusy do
					Citizen.Wait(100)
				end

				BusyspinnerOff()
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k,v in ipairs(vehicles) do
						if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							ESX.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end

			IsBusy = false
			ESX.ShowNotification(_U('garage_has_stored'))
		else
			ESX.ShowNotification(_U('garage_has_notstored'))
		end
	end, vehiclePlates)
end

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(_U('vehicleshop_awaiting_model'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

function GetAvailableVehicleSpawnPoint(station, part, partNum)
	local spawnPoints = Config.FBIStations[station][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		ESX.ShowNotification(_U('garage_blocked'))
		return false
	end
end