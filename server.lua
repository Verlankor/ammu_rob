local QBCore = exports['qb-core']:GetCoreObject()
local activeTruck
local activeDriver
local waitingFor = 0
local activePos
local  entityList = {}

CreateThread(function()
    Wait(1000)
    while true do
        StartRun()
        Wait(Config.Timer)
    end
end)

RegisterNetEvent('Ammu_Rob:VehicleReady', function(netID, driver)
    local source = source
    if waitingFor == source then
        waitingFor = 0
        local veh = NetworkGetEntityFromNetworkId(netID)
        activeTruck = veh
        activeDriver = NetworkGetEntityFromNetworkId(driver)
        entityList[activeTruck] = true
        entityList[activeDriver] = true
        while not DoesEntityExist(activeTruck) do
            Wait(100)
        end
        Wait(100)
        Entity(veh).state.ammurob = true

        while #(GetEntityCoords(activeTruck) - Config.EndPoint) > 10.0 do
            Wait(500)
        end
        Wait(1000)

        Entity(veh).state.ammurob = false
        Entity(activeDriver).state.ammurob = true
        TaskGoToCoordAnyMeans(activeDriver, Config.AmmunationCounter, 1.0, 0, 0, 786603, 0xbf800000)
        Wait(30000)
        print('[Ammu-Rob] Delivery has completed with no robbery')
        if DoesEntityExist(activeDriver) and GetEntityHealth(activeDriver) >= 0 then
            local player = GetPlayerInArea(Config.EndPoint, 200.0)
            if player then
                TriggerClientEvent('Ammu_Rob:Inside', player, driver, netID)
            end
            TrashEntityData()
        else
            activeDriver, activeTruck = nil, nil
        end
    end
end)

RegisterNetEvent('Ammu_Rob:Loot', function()
    local source = source
    if activeTruck == nil then return end
    local Player = QBCore.Functions.GetPlayer(source)
    if ((#(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(activeTruck)) <= 10.0)
    and QBCore.Functions.HasItem(source, "lockpick", 1))
    or (#(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(activeDriver)) <= 10.0) then
        for i=1,math.random(1,3) do
            local item = Config.Loot[math.random(#Config.Loot)]
            if Player.Functions.AddItem(item, math.random(2,3), true) then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
            end
        end
        print('[Ammu-Rob] Delivery has been Robbed')
        TrashEntityData()
    end
end)

AddStateBagChangeHandler(false, false, function(bagName, key, value, source, replicated)
    local entityNet = tonumber(bagName:gsub('entity:', ''), 10)
    local entity = NetworkGetEntityFromNetworkId(entityNet)
    if entityList[entity] then
        local ent = Entity(entity)
        local curState = ent.state[key]

        if source ~= 0 then
            SetTimeout(0, function()
                print('[Ammu-Rob] Removed Altered State Bag by Client: '..bagName, key, value)
                Entity(entity).state[key] = curState
            end)
        end
    end
end)

function StartRun()
    if activeDriver then
        if DoesEntityExist(activeDriver) then DeleteEntity(activeDriver) end
        if DoesEntityExist(activeTruck) then DeleteEntity(activeTruck) end
        activeDriver, activeTruck = nil, nil
    end
    activePos = Config.VehicleSpawns[math.random(#Config.VehicleSpawns)]
    local player = GetPlayerInArea(activePos, 200.0)
    while not player do
        print('[Ammu-Rob] No players in spawn area, waiting 60 seconds')
        Wait(60000)
        player = GetPlayerInArea(activePos, 200.0)
    end
    waitingFor = tonumber(player)
    TriggerClientEvent('Ammu_Rob:Start', player, activePos, Config.TransportModels[math.random(#Config.TransportModels)])
end

function GetPlayerInArea(pos, maxDist)
    local closestPlayer
    local distance = 99999.0
    for k,v in pairs(GetPlayers()) do
        local _dist = #(GetEntityCoords(GetPlayerPed(v)) - vec(pos.x, pos.y, pos.z))
        if _dist < distance then
            distance = _dist
            closestPlayer = v
        end
    end

    if distance > maxDist then return end
    return closestPlayer
end

function TrashEntityData()
    Entity(activeTruck).state.ammurob = false
    Entity(activeDriver).state.ammurob = false
    entityList[activeTruck] = nil
    entityList[activeDriver] = nil
    activeTruck = nil
    activeDriver = nil
end

exports('StartRun', StartRun)