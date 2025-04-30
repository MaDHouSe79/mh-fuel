--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
        DeleteBlips()
        DeleteTanks()
        DespawnTruckAndTrailer()
        DeleteStationZones()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('mh-fuel:server:onjoin')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('mh-fuel:server:onjoin')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('mh-fuel:client:refreshStations', function(GasStations)
    if isLoggedIn then
        config.GasStations = GasStations
        DeleteBlips()
        Wait(50)
        LoadBlips()
    end
end)

RegisterNetEvent('mh-fuel:client:notify', function(message, type, length)
    Notify(message, type, length)
end)

RegisterNetEvent('mh-fuel:client:onjoin', function(data)
    PlayerData = QBCore.Functions.GetPlayerData()
    config = data
    config.ShopItems = data.ShopItems
    config.GasStations = data.GasStations
    isLoggedIn = true
    DeleteBlips()
    Wait(25)
    GetPumpModel()
    LoadBlips()
    SpanShopPeds()
    SpawnStationPeds()
    CreateZones()
    CreateStationLoadPointTarget()
end)

-- Set fuel by an admin 
RegisterNetEvent('mh-fuel:client:setFuel', function(amount)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= -1 and DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
        print(vehicle, amount)
        SetFuel(vehicle, amount + 0.0)
    end
end)

RegisterNetEvent('mh-fuel:client:fixVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= -1 and DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleFixed(vehicle)
        for i = 0, 5 do SetVehicleTyreFixed(vehicle, i) end
        for i = 0, 7 do FixVehicleWindow(vehicle, i) end
        SetFuel(vehicle, 100.0)
    end
end)

RegisterNetEvent('mh-fuel:client:PlayWithinDistance', function(otherPlayerCoords, maxDistance, soundFile, soundVolume)
    if isLoggedIn then
        local myCoords = GetEntityCoords(PlayerPedId())
        local distance = #(myCoords - otherPlayerCoords)
        if distance < maxDistance then
            SendNUIMessage({ type = 'play', file = soundFile, volume = soundVolume or maxVolume })
        end
    end
end)

RegisterNetEvent('mh-fuel:client:syncAttachEntitiesToRope')
AddEventHandler('mh-fuel:client:syncAttachEntitiesToRope', function(connecction1_netid, connecction2_netid)
    CreateHose(NetworkGetEntityFromNetworkId(connecction1_netid), NetworkGetEntityFromNetworkId(connecction2_netid))
end)

RegisterNetEvent('mh-fuel:client:syncDetachEntitiesToRope')
AddEventHandler('mh-fuel:client:syncDetachEntitiesToRope', function(rope, connecction1_netid, connecction2_netid)
    DeleteHose(rope, NetworkGetEntityFromNetworkId(connecction1_netid), NetworkGetEntityFromNetworkId(connecction2_netid))
end)

RegisterNetEvent('mh-fuel:client:stopFuellingTrailer')
AddEventHandler('mh-fuel:client:stopFuellingTrailer', function()
    if isFuelingTrailer then
        isFuelingTrailer = false
        Notify(Lang:t('company_money_empty'), "error")
    end
end)

RegisterNetEvent('mh-fuel:client:stopFuellingStation')
AddEventHandler('mh-fuel:client:stopFuellingStation', function()
    if isFuelingStation then
        isFuelingStation = false
        Notify(Lang:t("tank_is_full"), "error")
    end
end)

RegisterNetEvent('mh-fuel:client:spawnlaodpoint')
AddEventHandler('mh-fuel:client:spawnlaodpoint', function(data)
    DeleteTanks()
    SpawnLoadPoint(data)
end)