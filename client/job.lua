--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --
--- Create Load Point Target Load fuel for trailers
function CreateLoadPointTarget(prop)
    local num = 1
    exports["qb-target"]:AddTargetModel(prop, {
        options = {{
            name = "station_load_point" .. num,
            icon = config.Fontawesome.pump,
            label = Lang:t('select_pump'),
            action = function(entity)
                tankEntity = entity
                SpawnPumpConnection(tankEntity)
            end,
            canInteract = function(entity, distance, data)
                if tankEntity ~= nil then return false end
                if trailerEntity == nil then return false end
                if isAttach then return false end
                return true
            end
        }, {
            name = "attach_hose_point" .. num,
            icon = config.Fontawesome.pump,
            label = Lang:t('attach_hose'),
            action = function(entity)
                TaskTurnPedToFaceEntity(PlayerPedId(), entity, 5000)
                Wait(1500)
                ClearPedTasks(PlayerPedId())
                SpawnLoadHose()
            end,
            canInteract = function(entity, distance, data)
                if tankEntity == nil then return false end
                if isAttach then return false end
                return true
            end
        }, {
            name = "detach_hose_point" .. num,
            icon = config.Fontawesome.pump,
            label = Lang:t('detach_hose'),
            action = function(entity)
                RemoveLoadHose()
                DeleteMissionBlip()
            end,
            canInteract = function(entity, distance, data)
                if tankEntity == nil then return false end
                if not isAttach then return false end
                if isFuelingTrailer then return false end
                return true
            end
        }, {
            name = "start_point" .. num,
            icon = config.Fontawesome.pump,
            label = Lang:t('start'),
            action = function(entity)
                TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "refuel", maxVolume)
                isFuelingTrailer = true
            end,
            canInteract = function(entity, distance, data)
                if tankEntity == nil then return false end
                if not isAttach then return false end
                if isFuelingTrailer then return false end
                if isTankFull then return false end
                return true
            end
        }, {
            name = "stop_point" .. num,
            icon = config.Fontawesome.stop,
            label = Lang:t('stop'),
            action = function(entity)
                TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "fuelstop", maxVolume)
                isFuelingTrailer = false
            end,
            canInteract = function(entity, distance, data)
                if tankEntity == nil then return false end
                if not isFuelingTrailer then return false end
                if isTankFull then return false end
                return true
            end
        }},
        distance = 2.5
    })
end

--- Create Station Load Point Target
function CreateStationLoadPointTarget()
    local options = {}
    for k, station in pairs(config.GasStations) do
        local model = "prop_gas_tank_04a"
        local current = GetHashKey(model)
        LoadModel(current)
        if station.loadPoint.x ~= 0.0 and station.loadPoint.y ~= 0.0 and station.loadPoint.z ~= 0.0 then
            local loadCoords = station.loadPoint
            local loadpoint = CreateObjectNoOffset(current, loadCoords.x, loadCoords.y, loadCoords.z - 1, 1, 0, 1)
            PlaceObjectOnGroundProperly(loadpoint)
            SetEntityHeading(loadpoint, loadCoords.w)
            SetEntityAsMissionEntity(loadpoint, true, true)
            FreezeEntityPosition(loadpoint, true)
            SetModelAsNoLongerNeeded(current)
            tanks[#tanks + 1] = { prop = model, coords = loadCoords.coords, entity = loadpoint }
            exports["qb-target"]:AddTargetEntity(loadpoint, {
                options = {{
                    name = "select_pump" .. k,
                    icon = config.Fontawesome.pump,
                    label = Lang:t('select_pump'),
                    action = function(entity)
                        tankEntity = entity
                        SpawnTankConnection(tankEntity)
                    end,
                    canInteract = function(entity, distance, data)
                        if trailerEntity == nil then return false end
                        if isAttach then return false end
                        return true
                    end
                }, {
                    name = "attach_hose" .. k,
                    icon = config.Fontawesome.pump,
                    label = Lang:t('attach_hose'),
                    action = function(entity)
                        TaskTurnPedToFaceEntity(PlayerPedId(), entity, 5000)
                        Wait(1500)
                        ClearPedTasks(PlayerPedId())
                        SpawnLoadHose()
                    end,
                    canInteract = function(entity, distance, data)
                        if tankEntity == nil then return false end
                        if isAttach then return false end
                        return true
                    end
                }, {
                    name = "detach_hose" .. k,
                    icon = config.Fontawesome.pump,
                    label = Lang:t('detach_hose'),
                    action = function(entity)
                        isAttach = false
                        isFuelingStation = false
                        RemoveLoadHose()
                    end,
                    canInteract = function(entity, distance, data)
                        if tankEntity == nil then return false end
                        if not isAttach then return false end
                        return true
                    end
                }, {
                    name = "start_fueling" .. k,
                    icon = config.Fontawesome.pump,
                    label = Lang:t('start'),
                    action = function(entity)
                        isFuelingStation = true
                    end,
                    canInteract = function(entity, distance, data)
                        if tankEntity == nil then return false end
                        if not isAttach then return false end
                        if isFuelingStation then return false end
                        return true
                    end
                },{
                    name = "stop_fueling" .. k,
                    icon = config.Fontawesome.pump,
                    label = Lang:t('stop'),
                    action = function(entity)
                        isFuelingStation = false
                    end,
                    canInteract = function(entity, distance, data)
                        if tankEntity == nil then return false end
                        if not isAttach then return false end
                        if not isFuelingStation then return false end
                        return true
                    end
                }
            },
                distance = 2.5
            })
        end
    end

    exports['qb-target']:AddTargetModel(config.DeliverTrailer, {
        options = {{
            name = "select_a_trailer",
            type = "client",
            event = "",
            icon = 'car',
            label = Lang:t('select_trailer'),
            action = function(entity)
                trailerEntity = entity
                FreezeEntityPosition(trailerEntity, true)
            end,
            canInteract = function(entity, distance, data)
                if trailerEntity ~= nil then return false end
                return true
            end
        },{
            name = "opentrailerstorage",
            icon = config.Fontawesome.pump,
            label = "Open Storage",
            action = function(entity)
                local plate = GetPlate(entity)
                TriggerServerEvent('mh-fuel:server:opentrailerstorage', plate)
            end,
            canInteract = function(entity, distance, data)
                return true
            end
        }},
        distance = 2.5
    })

end

--- Delete Tanks
function DeleteTanks()
    for _, tank in pairs(tanks) do
        if DoesEntityExist(tank.entity) then
            DeleteEntity(tank.entity)
        end
    end
end

--- Delete Hose
---@param rope number
---@param connecction1 number
---@param connecction2 number
function DeleteHose(rope, connecction1, connecction2)
    for k, v in pairs(ropes) do
        if v.id == rope then
            RopeUnloadTextures()
            DeleteRope(k)
        end
    end
    if DoesEntityExist(connecction2) then
        DeleteEntity(connecction2)
    end
end

--- Create Hose
---@param connecction1 number
---@param connecction2 number
function CreateHose(connecction1, connecction2)
    DeleteMissionBlip()
    local entity1Pos = GetEntityCoords(connecction1)
    entity1Pos = GetOffsetFromEntityInWorldCoords(connecction1, 0.0, -0.033, -0.195)
    local entity2Pos = GetEntityCoords(connecction2)
    entity2Pos = GetOffsetFromEntityInWorldCoords(connecction2, 0.0, -0.033, -0.195)
    local distance = GetDistance(entity1Pos, entity2Pos)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(1)
        RopeLoadTextures()
    end
    rope = AddRope(entity2Pos.x, entity2Pos.y, entity2Pos.z, 0.0, 0.0, 0.0, distance + 0.3, 3, 100.0, 0.0, 1.0, false, false, false, 1.0, true)
    if not ropes[rope] then ropes[rope] = { id = rope } end
    while not rope do Wait(0) end
    ActivatePhysics(ropes[rope].id)
    AttachEntitiesToRope(ropes[rope].id, connecction2, connecction1, entity2Pos.x, entity2Pos.y, entity2Pos.z, entity1Pos.x, entity1Pos.y, entity1Pos.z, false, false, nil, nil)
end

-- Spawn Load Hose
function SpawnLoadHose()
    if tankEntity ~= nil and trailerEntity ~= nil then
        disableControll = true
        FreezeEntityPosition(PlayerPedId(), true)
        LoadAnimDict("amb@world_human_gardener_plant@male@base")
        TaskPlayAnim(PlayerPedId(), "amb@world_human_gardener_plant@male@base", "base", 3.0, 3.0, -1, 49, 0, false, false, false)
        Wait(5000)
        StopAnimTask(PlayerPedId(), "amb@world_human_gardener_plant@male@base", "base", 1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        local con1 = NetworkGetNetworkIdFromEntity(spawnedPipe)
        local con2 = NetworkGetNetworkIdFromEntity(spawnedHoseConnection)
        TriggerServerEvent('mh-fuel:server:syncAttachEntitiesToRope', con1, con2)
        spawnedHose = rope
        isAttach = true
        FreezeEntityPosition(PlayerPedId(), false)
        Wait(1000)
        disableControll = false
    end
end

-- Remove Load Hose
function RemoveLoadHose()
    FreezeEntityPosition(PlayerPedId(), true)
    local con1 = NetworkGetNetworkIdFromEntity(spawnedPipe)
    local con2 = NetworkGetNetworkIdFromEntity(spawnedHoseConnection)
    disableControll = true
    FreezeEntityPosition(PlayerPedId(), true)
    LoadAnimDict("amb@world_human_gardener_plant@male@base")
    TaskPlayAnim(PlayerPedId(), "amb@world_human_gardener_plant@male@base", "base", 3.0, 3.0, -1, 49, 0, false, false, false)
    Wait(5000)
    StopAnimTask(PlayerPedId(), "amb@world_human_gardener_plant@male@base", "base", 1.0)
    TriggerServerEvent('mh-fuel:server:syncDetachEntitiesToRope', rope, con1, con2)
    spawnedHose = nil
    isAttach = false
    isFuelingTrailer = false
    FreezeEntityPosition(trailerEntity, false)
    FreezeEntityPosition(PlayerPedId(), false)
    tankEntity = nil
    Wait(1000)
    disableControll = false
end

--- Spawn Pump Pipe
function SpawnPumpConnection(tankEntity)
    if DoesEntityExist(spawnedHoseConnection) then DeleteEntity(spawnedHoseConnection) end
    if currentTrailer ~= nil then
        local model = "prop_cs_fuel_nozle"
        local current = GetHashKey(model)
        LoadModel(current)
        spawnedHoseConnection = CreateObject(model, 0, 0, 0, true, true, true)
        local pos = { x = 0.0, y = -0.02, z = 1.4 }
        local rot = { x = 10.0, y = -180.0, z = 10.0 }
        AttachEntityToEntity(spawnedHoseConnection, tankEntity, 0, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
    end
end

--- Spawn Tank Connection
function SpawnTankConnection(tankEntity)
    if DoesEntityExist(spawnedHoseConnection) then DeleteEntity(spawnedHoseConnection) end
    if currentTrailer ~= nil then
        local model = "prop_cs_fuel_nozle"
        local current = GetHashKey(model)
        LoadModel(current)
        spawnedHoseConnection = CreateObject(model, 0, 0, 0, true, true, true)
        local pos = { x = -1.0, y = 0.0, z = 2.27 }
        local rot = { x = 0.0, y = -180.0, z = 175.0 }
        AttachEntityToEntity(spawnedHoseConnection, tankEntity, 0, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
    end
end

--- Spawn Trailer Connection
function SpawnTrailerConnection()
    if currentTrailer ~= nil then
        local model = "prop_cs_fuel_nozle"
        local current = GetHashKey(model)
        LoadModel(current)
        local bone = GetEntityBoneIndexByName(currentTrailer, "indicator_rr")
        spawnedPipe = CreateObject(model, 0, 0, 0, true, true, true)
        local pos = { x = -1.0, y = 0.55, z = 2.45 }
        local rot = { x = 90.5, y = -180.0, z = 180.0 }
        AttachEntityToEntity(spawnedPipe, currentTrailer, bone, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
    end
end

--- Delete Load Point Blip
function DeleteLoadPointBlip()
    if DoesBlipExist(loadBlip) then
        RemoveBlip(loadBlip)
    end
end

--- Create Load point Blip
---@param station table
function CreateLoadpointBlip(station)
    DeleteLoadPointBlip()
    local blip = AddBlipForCoord(station.coords)
    SetBlipSprite(blip, station.blip.sprite)
    SetBlipScale(blip, station.blip.scale)
    SetBlipColour(blip, station.blip.color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(station.blip.label)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, true)
    loadBlip = blip
end

--- Spawn Truck
---@param model string
---@param position table
---@param heading number
function SpawnTruck(model, position, heading)
    LoadModel(model)
    local spawnpoint = vector3(position.x, position.y, position.z)
    local vehicle = CreateVehicle(model, spawnpoint, heading, true, true)
    local plate = 'TRUCK' .. math.random(100, 999)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, plate)
    SetEntityHeading(vehicle, heading)
    SetFuel(vehicle, 100.0)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleDirtLevel(vehicle, 0)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    GiveVehicleKeyToPlayer(vehicle, plate)
    SetModelAsNoLongerNeeded(model)
    return vehicle, plate
end

--- Spawn railer
---@param model string
---@param position table
---@param heading number
function SpawnTrailer(model, position, heading)
    LoadModel(model)
    local spawnpoint = vector3(position.x, position.y, position.z)
    local vehicle = CreateVehicle(model, spawnpoint, heading, true, false)
    local plate = 'TRAILER' .. math.random(100, 999)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, plate)
    SetEntityHeading(vehicle, heading)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
    SetVehicleDirtLevel(vehicle, 0)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetModelAsNoLongerNeeded(model)
    return vehicle, plate
end

--- Despawn Truck And Trailer
function DespawnTruckAndTrailer()
    if isAttach then
        Notify("You trailer is still attached to the tank.")
    else
        if DoesEntityExist(currentTruck) then DeleteEntity(currentTruck) end
        if DoesEntityExist(currentTrailer) then DeleteEntity(currentTrailer) end
        if DoesEntityExist(spawnedPipe) then DeleteEntity(spawnedPipe) end
        if DoesBlipExist(loadpointBlip) then RemoveBlip(loadpointBlip) end
        DeleteMissionBlip()
        spawnedPipe = nil
        currentTruck = nil
        currentTrailer = nil
        loadpointBlip = nil
    end
end

--- Get Random Point
function GetRandomPoint()
    return config.LoadPoints[math.random(1, #config.LoadPoints)]
end

--- Spawn Load Point
---@param data table
function SpawnLoadPoint(data)
    if not data.hasTank then
        LoadModel(data.tankProp)
        local tank = CreateObjectNoOffset(data.tankProp, data.tankCoords.x, data.tankCoords.y, data.tankCoords.z - 1.5, 1, 0, 1)
        while not DoesEntityExist(tank) do Wait(1) end
        PlaceObjectOnGroundProperly(tank)
        SetEntityHeading(tank, data.tankCoords.w)
        SetEntityAsMissionEntity(tank, true, true)
        FreezeEntityPosition(tank, true)
        SetModelAsNoLongerNeeded(data.prop)
        data.entity1 = tank
        tanks[#tanks + 1] = { prop = data.prop, coords = data.tankCoords, entity = tank }
    end
    LoadModel(data.prop)
    local loadpoint = CreateObjectNoOffset(data.prop, data.coords.x, data.coords.y, data.coords.z - 1.5, 1, 0, 1)
    while not DoesEntityExist(loadpoint) do Wait(1) end
    PlaceObjectOnGroundProperly(loadpoint)
    SetEntityHeading(loadpoint, data.coords.w)
    SetEntityAsMissionEntity(loadpoint, true, true)
    FreezeEntityPosition(loadpoint, true)
    SetModelAsNoLongerNeeded(data.prop)
    data.entity = loadpoint
    tanks[#tanks + 1] = { prop = data.prop, coords = data.coords, entity = loadpoint }
    CreateLoadPointTarget(data.prop)
    CreateLoadpointBlip(data)
    CreateMissionBlip(data.coords)
end

--- Span Shop Peds
function SpanShopPeds()
    for k, shop in pairs(config.BuyStationsStores) do
        local model = shop.ped
        local current = GetHashKey(model)
        LoadModel(current)
        local menuped = CreatePed(0, current, shop.coords.x, shop.coords.y, shop.coords.z - 1, shop.coords.w, true, false)
        TaskStartScenarioInPlace(menuped, "WORLD_HUMAN_STAND_MOBILE", true)
        FreezeEntityPosition(menuped, true)
        SetEntityInvincible(menuped, true)
        SetPedKeepTask(menuped, true)
        SetBlockingOfNonTemporaryEvents(menuped, true)
        peds[#peds + 1] = menuped
    end
end

--- Spawn Truck And Trailer
---@param truckModel string
---@param trailerModel string
---@param coords table
function SpawnTruckAndTrailer(truckModel, trailerModel, coords)
    local heading = coords.w
    if truckModel ~= nil then
        currentTruck, currentTruckPlate = SpawnTruck(truckModel, coords, heading)
        heading = GetEntityHeading(currentTruck)
    end
    if trailerModel ~= nil then
        local coords = GetOffsetFromEntityInWorldCoords(currentTruck, 0.0, -7.5, 0.0)
        local position = vector3(coords.x, coords.y, coords.z)
        currentTrailer, currentTrailerPlate = SpawnTrailer(trailerModel, position, heading)
        isTankFull = false
        SpawnTrailerConnection()
        trailerEntity = currentTrailer
        local loadPoint = GetRandomPoint()
        SpawnLoadPoint(loadPoint)
    end
end

--- Refresh Stations
function RefreshStations()
    TriggerServerEvent('mh-fuel:server:RefreshStations')
end

--- Delete Station Zones
function DeleteStationZones()
    for k, zone in pairs(stationZones) do
        if zone ~= nil then zone:destroy() end
    end
end

--- Spawn Station Peds
function SpawnStationPeds()
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetAllStations", function(stations)
        for k, station in pairs(stations) do
            local model = "a_m_m_hillbilly_01"
            local current = GetHashKey(model)
            LoadModel(current)
            local menuCoords = station.menuCoords
            local menuped = CreatePed(0, current, menuCoords.x, menuCoords.y, menuCoords.z - 1, menuCoords.w, true, false)
            TaskStartScenarioInPlace(menuped, "WORLD_HUMAN_STAND_MOBILE", true)
            FreezeEntityPosition(menuped, true)
            SetEntityInvincible(menuped, true)
            SetPedKeepTask(menuped, true)
            SetBlockingOfNonTemporaryEvents(menuped, true)
            peds[#peds + 1] = menuped
        end
    end)
end

--- Open Garage Menu
---@param id number
function OpenGarageMenu(id)
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetStationData", function(station)
        local options = {}
        if station ~= false and station.id == id and station.citizenid == PlayerData.citizenid then
            if currentTruck ~= nil and currentTrailer ~= nil then
                options[#options + 1] = {
                    title = Lang:t('park_truck'),
                    icon = config.Fontawesome.trucks,
                    description = '',
                    arrow = false,
                    onSelect = function()
                        if isAttach then
                            Notify(Lang:t('trailer_is_still_connected_to_tank'))
                        else
                            DespawnTruckAndTrailer()
                        end
                    end
                }
            end
            if currentTruck == nil and currentTrailer == nil then
                options[#options + 1] = {
                    title = Lang:t('get_truck'),
                    icon = config.Fontawesome.trucks,
                    description = '',
                    arrow = false,
                    onSelect = function()
                        currentJobId = id
                        SpawnTruckAndTrailer(config.DeliverVehicle, config.DeliverTrailer, station.spawnPoint)
                    end
                }
            end
        end
        options[#options + 1] = {
            title = Lang:t('back'),
            icon = config.Fontawesome.goback,
            description = '',
            arrow = false,
            onSelect = function()
                OpenStationMenu(id)
            end
        }
        lib.registerContext({
            id = 'stationMenu',
            title = Lang:t('garage_menu'),
            icon = config.Fontawesome.trailers,
            options = options
        })
        lib.showContext('stationMenu')
    end, id)
end

--- Company Money Menu
---@param id number
function CompanyMoneyMenu(id)
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetStationData", function(station)
        local options = {}
        if station ~= false and station.id == id and station.citizenid == PlayerData.citizenid then
            options[#options + 1] = {
                title = Lang:t('current_money'),
                icon = config.Fontawesome.boss,
                description = Lang:t('current_money') .. ' ' .. config.MoneySign .. station.company_money,
                arrow = false,
                onSelect = function()
                    CompanyMoneyMenu(id)
                end
            }
            options[#options + 1] = {
                title = Lang:t('add_money'),
                icon = config.Fontawesome.boss,
                description = Lang:t('add_money_to_account'),
                arrow = false,
                onSelect = function()
                    local input = lib.inputDialog(Lang:t('add_money'), {{
                        type = 'number',
                        label = Lang:t('add_company_money'),
                        description = Lang:t('add_money'),
                        required = true,
                        icon = 'hashtag'
                    }})
                    if not input then return CompanyMoneyMenu(station.id) end
                    TriggerServerEvent('mh-fuel:server:AddMoney', station.id, input[1], true)
                    RefreshStations()
                end
            }
            options[#options + 1] = {
                title = Lang:t('take_money'),
                icon = config.Fontawesome.boss,
                description = Lang:t('take_money_from_account'),
                arrow = false,
                onSelect = function()
                    local input = lib.inputDialog(Lang:t('take_money'), {{
                        type = 'number',
                        label = Lang:t('take_company_money'),
                        description = Lang:t('take_money'),
                        required = true,
                        icon = 'hashtag'
                    }})
                    if not input then return CompanyMoneyMenu(station.id) end
                    TriggerServerEvent('mh-fuel:server:TakeMoney', station.id, input[1], true)
                    RefreshStations()
                end
            }
        end
        options[#options + 1] = {
            title = Lang:t('back'),
            icon = config.Fontawesome.goback,
            description = '',
            arrow = false,
            onSelect = function()
                ManageStationDataMenu(station.id)
            end
        }
        lib.registerContext({
            id = 'companymoneyMenu',
            title = Lang:t('company_money_menu'),
            icon = config.Fontawesome.trailers,
            options = options
        })
        lib.showContext('companymoneyMenu')
    end, id)
end

--- Buy GasStation Menu
function BuyGasStationMenu()
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetAllStations", function(stations)
        local options = {}
        for k, station in pairs(stations) do
            local streetname = nil
            local street = GetStreetNametAtCoords(station.coords)
            if street.cross == "" then
                streetname = street.main
            else
                streetname = street.main .. " - " .. street.cross
            end
            local hasmlo = Lang:t('no')
            if station.hasMLO then hasmlo = Lang:t('yes') end
            if station.citizenid ~= "none" and station.citizenid == PlayerData.citizenid then
                options[#options + 1] = {
                    title = streetname,
                    icon = config.Fontawesome.buy,
                    description = Lang:t('selling_station_description', { id=station.id, mlo=hasmlo, username=station.username, street=streetname, capacity=station.max_capacity}),
                    arrow = false,
                    onSelect = function()
                        local username = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
                        local alert = lib.alertDialog({
                            header = Lang:t('hello_user', {username=username}),
                            content = Lang:t('selling_station'),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent('mh-fuel:server:SellStation', station.id)
                            RefreshStations()
                        end
                    end
                }
            end

            if station.citizenid == "none" then
                options[#options + 1] = {
                    title = streetname,
                    icon = config.Fontawesome.buy,
                    description = Lang:t('selling_station_description', { id=station.id, mlo=hasmlo, username="Nobody", street=streetname, capacity=station.max_capacity}),
                    arrow = false,
                    onSelect = function()
                        local username = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
                        local alert = lib.alertDialog({
                            header = Lang:t('hello_user', {username=username}),
                            content = Lang:t('buying_station', {price =config.MoneySign .. station.buy_price}),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent('mh-fuel:server:BuyStation', station.id)
                            Wait(50)
                            RefreshStations()
                        end
                    end
                }
            end
        end
        options[#options + 1] = {
            title = Lang:t('close'),
            icon = config.Fontawesome.goback,
            description = '',
            arrow = false,
            onSelect = function()
                RefreshStations()
            end
        }
        lib.registerContext({
            id = 'buystationMenu',
            title = Lang:t('buy_station_menu'),
            icon = config.Fontawesome.trailers,
            options = options
        })
        lib.showContext('buystationMenu')
    end)
end

--- Create Zones
local stationCombo = nil
function CreateZones()

    for k, station in pairs(config.GasStations) do
        stationZones[#stationZones + 1] = CircleZone:Create(vector3(station.menuCoords.x,
            station.menuCoords.y, station.menuCoords.z), 2.0, {
            name = station.id,
            useZ = true,
            debugPoly = false
        })
    end

    stationCombo = ComboZone:Create(stationZones, { name = "StationZoneName", debugPoly = false })
    stationCombo:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            isInPedZone = true
            DrawText3D(Lang:t('press_to_open_station'))
            zoneId = zone.id
        else
            isInPedZone = false
            zoneId = -1
            HideText()
        end
    end)

    for k, shop in pairs(config.BuyStationsStores) do
        shopZone[#shopZone + 1] = CircleZone:Create(vector3(shop.coords.x, shop.coords.y, shop.coords.z), 2.0, {
            name = "shop_station",
            useZ = true,
            debugPoly = false
        })
        local shopCombo = ComboZone:Create(shopZone, { name = "BuyZoneName", debugPoly = false })
        shopCombo:onPlayerInOut(function(isPointInside, _, zone)
            if isPointInside then
                isInShopZone = true
                zoneId = zone.id
                DrawText3D(Lang:t('press_to_buy_station'))
            else
                isInShopZone = false
                zoneId = -1
                HideText()
            end
        end)
    end
end

--- Buy Station Items (For Owned Stations)
---@param id number, the id is the station id
function BuyStationItems(id)
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetStationData", function(station)
        local options = {}
        if station ~= false and station.id == id then
            for k, item in pairs(station.items) do
                local itemicon = config.BaseImagesFolder .. '/' .. item.name .. ".png"
                options[#options + 1] = {
                    title = item.label,
                    icon = itemicon,
                    description = Lang:t('buy_shop_item', {item = item.name, price = config.MoneySign .. item.price / 2}),
                    arrow = false,
                    onSelect = function()
                        local input = lib.inputDialog(Lang:t('amount'), {{
                            type = 'number',
                            description = Lang:t('item_amount', {item = item.name}),
                            required = true,
                            icon = 'hashtag'
                        }})
                        if not input then return end
                        TriggerServerEvent('mh-fuel:server:BuyItemForShop', id, item, tonumber(input[1]), item.price)
                        BuyStationItems(id)
                    end
                }
            end
            options[#options + 1] = {
                title = Lang:t('back'),
                icon = config.Fontawesome.goback,
                description = '',
                arrow = false,
                onSelect = function()
                    OpenStationMenu(id)
                end
            }
            lib.registerContext({
                id = 'stationStoreMenu',
                title = Lang:t('station_store'),
                icon = config.Fontawesome.shop,
                options = options
            })
            lib.showContext('stationStoreMenu')
        end
    end, id)
end

--- Change Station Data Menu
function ManageStationDataMenu(id)
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetStationData", function(station)
        local options = {}
        if station ~= false and station.id == id and station.citizenid == PlayerData.citizenid then
            options[#options + 1] = {
                title = Lang:t('manage_company_items'),
                icon = config.Fontawesome.store,
                description = Lang:t('manage_your_company_items'),
                arrow = false,
                onSelect = function()
                    BuyStationItems(station.id)
                end
            }
            options[#options + 1] = {
                title = Lang:t('manage_company_money'),
                icon = config.Fontawesome.boss,
                description = Lang:t('manage_your_company_money'),
                arrow = false,
                onSelect = function()
                    CompanyMoneyMenu(station.id)
                end
            }
            options[#options + 1] = {
                title = Lang:t('manage_company_name'),
                icon = config.Fontawesome.boss,
                description = Lang:t('manage_your_company_name'),
                arrow = false,
                onSelect = function()
                    local input = lib.inputDialog(Lang:t('manage_station'), {{
                        type = 'input',
                        label = Lang:t('current_company_name', {name=station.company_name}),
                        description = Lang:t('change_name'),
                        required = true,
                        min = 5,
                        max = 30
                    }})
                    if not input then return ManageStationDataMenu(station.id) end
                    TriggerServerEvent('mh-fuel:server:ChangeStationName', station.id, input[1])
                    RefreshStations()
                    ManageStationDataMenu(station.id)
                end
            }
            options[#options + 1] = {
                title = Lang:t('manage_blip_color'),
                icon = config.Fontawesome.boss,
                description = Lang:t('change_your_blip_color'),
                arrow = false,
                onSelect = function()
                    local input = lib.inputDialog('Change Station', {{
                        type = 'number',
                        label = Lang:t('current_color', {color=station.blip_color}),
                        description = Lang:t('change_color'),
                        required = true,
                        icon = 'hashtag'
                    }})
                    if not input then return ManageStationDataMenu(station.id) end
                    TriggerServerEvent('mh-fuel:server:ChangeStationColor', station.id, input[1])
                    RefreshStations()
                    ManageStationDataMenu(station.id)
                end
            }
            options[#options + 1] = {
                title = Lang:t('manage_fuel_price'),
                icon = config.Fontawesome.boss,
                description = Lang:t('change_fuel_price'),
                arrow = false,
                onSelect = function()
                    local input = lib.inputDialog(Lang:t('change_price'), {{
                        type = 'number',
                        label = Lang:t('current_fuel_price', {price=station.fuel_price}),
                        description = Lang:t('change_price'),
                        required = true,
                        icon = 'hashtag'
                    }})
                    if not input then return ManageStationDataMenu(station.id) end
                    TriggerServerEvent('mh-fuel:server:ChangeStationFuelPrice', station.id, input[1])
                    RefreshStations()
                    ManageStationDataMenu(station.id)
                end
            }           
        end
        options[#options + 1] = {
            title = Lang:t('back'),
            icon = config.Fontawesome.goback,
            description = '',
            arrow = false,
            onSelect = function()
                OpenStationMenu(station.id)
            end
        }
        lib.registerContext({
            id = 'stationMenu',
            title = Lang:t('manage_gasstation', {id=id}),
            icon = config.Fontawesome.trailers,
            options = options
        })
        lib.showContext('stationMenu')
    end, id)
end

--- Open Store Menu
---@param id number
function OpenStoreMenu(id)
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetStationData", function(station)
        local options = {}
        if station ~= false and station.id == id then
            if station.items ~= "no-items" then
                for k, item in pairs(station.items) do
                    if item.amount >= 1 then
                        options[#options + 1] = {
                            title = item.label,
                            icon = config.BaseImagesFolder .. '/' .. item.name .. ".png",
                            description = Lang:t('buy_shop_item', {item=item.name, price = config.MoneySign .. item.price}),
                            arrow = false,
                            onSelect = function()
                                local input = lib.inputDialog(Lang:t('amount'), {{type = 'number', description = Lang:t('item_amount', {item=item.name}), required = true, icon = 'hashtag'}})
                                if not input then return end
                                TriggerServerEvent('mh-fuel:server:BuyItemFromStore', station.id, item.name, input[1], item.price)
                            end
                        }
                    end
                end
                options[#options + 1] = {
                    title = Lang:t('back'),
                    icon = config.Fontawesome.goback,
                    description = '',
                    arrow = false,
                    onSelect = function()
                        OpenStationMenu(id)
                    end
                }
                lib.registerContext({
                    id = 'stationStoreMenu',
                    title = Lang:t('station_store'),
                    icon = config.Fontawesome.shop,
                    options = options
                })
                lib.showContext('stationStoreMenu')
            else
                Notify("This shop has no items in the store")
            end
        end
    end, id)
end

--- Open Station Menu
---@param id number
function OpenStationMenu(id)
    QBCore.Functions.TriggerCallback("mh-fuel:server:GetStationData", function(station)
        local options = {}
        if station ~= false and station.id == id then
            local owner = station.username
            local citizenid = station.citizenid
            if station.username == '' then owner = Lang:t('no_body') end
            if station.citizenid == '' then citizenid = Lang:t('unknow') end
            if config.StationsCanBeOwnedByPlayers then
                options[#options + 1] = {
                    description = Lang:t('station_description', {id=station.id, username=owner, citizenid=citizenid, max_capacity=Round(station.max_capacity, 2), current_capacity=Round(station.current_capacity, 2), price=config.MoneySign .. station.fuel_price}),
                    arrow = false,
                    onSelect = function()
                        OpenStationMenu(id)
                    end
                }
                if station.citizenid == PlayerData.citizenid then
                    options[#options + 1] = {
                        title = Lang:t('open_station'),
                        icon = config.Fontawesome.pump,
                        description = '',
                        arrow = false,
                        onSelect = function()
                            ManageStationDataMenu(station.id)
                        end
                    }
                    options[#options + 1] = {
                        title = Lang:t('open_garage'),
                        icon = config.Fontawesome.garage,
                        description = '',
                        arrow = false,
                        onSelect = function()
                            OpenGarageMenu(station.id)
                        end
                    }
                end
            end
            options[#options + 1] = {
                title = Lang:t('open_shop'),
                icon = config.Fontawesome.shop,
                description = '',
                arrow = false,
                onSelect = function()
                    OpenStoreMenu(station.id)
                end
            }
            options[#options + 1] = {
                title = Lang:t('close'),
                icon = config.Fontawesome.goback,
                description = '',
                arrow = false,
                onSelect = function()
                    DrawText3D(Lang:t('press_to_open_station'))
                end
            }
            lib.registerContext({
                id = 'stationMenu',
                title = Lang:t('gasstation_menu', {id=id}),
                icon = config.Fontawesome.pump,
                options = options
            })
            lib.showContext('stationMenu')
        end
    end, id)
end

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and disableControll and not PlayerData.metadata['isdead'] then
            sleep = 5
            if IsPauseMenuActive() then SetFrontendActive(false) end
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 322, true)
            EnableControlAction(0, 288, true)
            EnableControlAction(0, 213, true)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            EnableControlAction(0, 47, true)
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            if isInPedZone and zoneId ~= -1 then
                sleep = 5
                if IsControlJustPressed(0, 38) then
                    OpenStationMenu(zoneId)
                    HideText()
                    sleep = 1000
                end
            end
            if isInShopZone and zoneId ~= -1 then
                sleep = 5
                if IsControlJustPressed(0, 38) then
                    BuyGasStationMenu()
                    HideText()
                    sleep = 1000
                end
            end
        end
        Wait(sleep)
    end
end)

-- Refueling Trailer/Station
local payfuelprice = 0
CreateThread(function()
    while true do
        Wait(2000)
        if isLoggedIn then
            while isFuelingTrailer do
                if trailerfuel < config.TrailerMaxCapacity then  
                    payfuelprice = config.GasStations[currentJobId].fuel_price / 2 * trailerfuel
                    QBCore.Functions.TriggerCallback("mh-fuel:server:HasMoney", function(hasMoney)
                        if hasMoney then
                            isTankFull = false
                            trailerfuel = trailerfuel + 1
                            TriggerServerEvent('mh-fuel:server:TakeMoney', currentJobId, price, false)
                        elseif not hasMoney then
                            isFuelingTrailer = false
                        end
                    end, currentJobId, payfuelprice)
                else
                    isTankFull = true
                    isFuelingTrailer = false
                    Notify(Lang:t('no_more_fuel_can_be_added'), "success")
                end
                Wait(100)
            end

            while isFuelingStation do
                if trailerfuel > 0 then
                    isTankFull = true
                    trailerfuel = trailerfuel - 1
                    TriggerServerEvent('mh-fuel:server:AddFuelToTank', currentJobId, 1)
                else
                    isTankFull = false
                    isFuelingStation = false
                    currentJobId = nil
                    Notify(Lang:t('no_more_fuel_in_trailer'), "error")
                end
                Wait(100)
            end
        end
    end
end)

-- Display Refueling Trailer/Station
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            if isAttach and trailerEntity ~= nil then
                sleep = 5
                local coords = GetEntityCoords(trailerEntity)
                Draw3DText(coords.x, coords.y, coords.z + 1.0, Round(trailerfuel, 2) .. "/" .. config.TrailerMaxCapacity .. " LITER")
            end
            if vehicleFueling and isNozzleInVehicle and lastVehicle ~= nil then
                sleep = 5
                local tankPosition = GetWorldPositionOfEntityBone(lastVehicle, tankBone)
                local fuel = GetFuel(lastVehicle)
                Draw3DText(tankPosition.x, tankPosition.y, tankPosition.z + 1.0, Lang:t('fuel', {fuel = fuel}))
            end
        end
        Wait(sleep)
    end
end)
