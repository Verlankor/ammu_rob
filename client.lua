local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('Ammu_Rob:Start', function(pos, vehModel)
    QBCore.Functions.SpawnVehicle(GetHashKey(vehModel), function(veh)
		RequestModel("s_m_m_security_01")
		while not HasModelLoaded("s_m_m_security_01") do
			Wait(10)
		end
		local driver = CreatePed(26, "s_m_m_security_01", pos.x, pos.y, pos.z, 0.0, true, false)
		SetModelAsNoLongerNeeded('s_m_m_security_01')
		SetPedIntoVehicle(driver, veh, -1)
		TaskVehicleDriveToCoordLongrange(driver, veh, vector3(28.71, -1110.68, 29.31), 10.0, 786603, 1.0)
		
		SetPedKeepTask(driver, true)
		SetBlockingOfNonTemporaryEvents(driver, true)
		SetEntityAsMissionEntity(driver)
		SetEntityAsMissionEntity(veh)

		Wait(1000)
        TriggerServerEvent('Ammu_Rob:VehicleReady', NetworkGetNetworkIdFromEntity(veh), NetworkGetNetworkIdFromEntity(driver))
		Wait(5000)
		Entity(veh).state:set('asshole', true, true)
	end, pos, true, false)
end)

RegisterNetEvent('Ammu_Rob:Inside', function(driver, vehicle)
	local driver = NetworkGetEntityFromNetworkId(driver)
	local vehicle = NetworkGetEntityFromNetworkId(vehicle)
	GetEntityControl(driver)
	TaskVehicleDriveWander(driver, vehicle, 80.0, 443)
	SetEntityAsNoLongerNeeded(driver)
	SetEntityAsNoLongerNeeded(vehicle)
end)

exports['qb-target']:AddTargetModel({`burrito`}, {
	options = {
		{
			action = function(entity)
				local breakDistance = false
				RequestAnimDict('mp_car_bomb')
				while not HasAnimDictLoaded('mp_car_bomb') do
					Wait(0)
				end
				TaskPlayAnim(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic' ,1.0, 1.0, -1, 16, 0, false, false, false)
				
				CreateThread(function()
					while lockpick do
						Wait(250)
						if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) >= 20.0 then
							breakDistance = true
							break
						end
					end
				end)
				
				local lockpicking = true
				TriggerEvent('qb-lockpick:client:openLockpick', function(weWon)
					lockpicking = false
					if breakDistance then return end
					if weWon then
						TriggerServerEvent('Ammu_Rob:Loot')
					else
						TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
					end
				end)	
			end,
			icon = "fas fa-sack-dollar",
			label = "Unlock Back",
			item = 'lockpick',
			canInteract = function(entity)
				return Entity(entity).state.ammurob == true
				and #(GetEntityCoords(PlayerPedId()) - GetOffsetFromEntityInWorldCoords(entity, 0.0, -3.0, 0.0)) < 1.5
			end,
		},
	},
	distance = 15.5,
})

exports['qb-target']:AddTargetModel({`s_m_m_security_01`}, {
	options = {
		{
			action = function(entity)
				if IsEntityDead(entity) then
					TriggerServerEvent('Ammu_Rob:Loot')
				else
					GetEntityControl(entity)
					GiveWeaponToPed(entity, GetHashKey('WEAPON_NIGHTSTICK'), 60, false, true)
					TaskCombatPed(entity, PlayerPedId(), 0 ,16)
				end
			end,
			icon = "fas fa-sack-dollar",
			label = "Grab Gun",
			canInteract = function(entity)
				return Entity(entity).state.ammurob == true
			end,
		},
	},
	distance = 2.5,
})

function GetEntityControl(ent)
    local wait = 0
    NetworkRequestControlOfEntity(ent)
    while not NetworkHasControlOfEntity(ent) do
        Wait(0)
        wait = wait + 1
        if wait > 15 then
            break
        end
    end

    return NetworkHasControlOfEntity(ent)
end