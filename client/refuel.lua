--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --

function GetVehicleFuelBonePosition(vehicle)
    local isBike = false
    local nozzleOffset = {x = 0.0, y = 0.0, z = 0.0}
    local textOffset = {x = 0.0, y = 0.0, z = 0.0}
    local tankBone = GetEntityBoneIndexByName(vehicle, "petrolcap")
    local vehClass = GetVehicleClass(vehicle)
    if vehClass == 8 then
        if tankBone == -1 then tankBone = GetEntityBoneIndexByName(vehicle, "petroltank") end
        if tankBone == -1 then tankBone = GetEntityBoneIndexByName(vehicle, "engine") end
        isBike = true
    elseif vehClass ~= 13 then
        if tankBone == -1 then tankBone = GetEntityBoneIndexByName(vehicle, "petroltank") end
        if tankBone == -1 then tankBone = GetEntityBoneIndexByName(vehicle, "petroltank_l") end
        if tankBone == -1 then tankBone = GetEntityBoneIndexByName(vehicle, "petroltank_r") end
        if tankBone == -1 then tankBone = GetEntityBoneIndexByName(vehicle, "hub_lr") end
        if tankBone == -1 then
            tankBone = GetEntityBoneIndexByName(vehicle, "handle_dside_r")
            nozzleOffset = {x = 0.1, y = -0.5, z = -0.6}
            textOffset = {x = 0.55, y = 0.1, z = -0.2}
        end
    end
    return tankBone, nozzleOffset, textOffset, isBike
end

function PutNozzleInVehicle()
    local tankBone, nozzlePosition, textPosition, isBike = GetVehicleFuelBonePosition(lastVehicle)
    local tankPosition = GetWorldPositionOfEntityBone(lastVehicle, tankBone)
    TaskTurnPedToFaceCoord(PlayerPedId(), tankPosition, 5000)
    Citizen.Wait(1000)
    isNozzleInVehicle = true
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(PlayerPedId(), "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "pickupnozzle", maxVolume)
    Wait(300)
    ClearPedTasks(PlayerPedId())
    AttachEntityToEntity(spawnedNozzle, lastVehicle, tankBone, -0.18 + nozzlePosition.x, 0.0 + nozzlePosition.y, 0.75 + nozzlePosition.z - 0.2, -125.0, -90.0, -90.0, true, true, false, false, 1, true)
    vehicleFueling = true
    TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "refuel", maxVolume)
end

function TakeFromVehicle()
    tankBone, nozzlePosition, textPosition, isBike = GetVehicleFuelBonePosition(lastVehicle)
    local tankPosition = GetWorldPositionOfEntityBone(lastVehicle, tankBone)
    TaskTurnPedToFaceCoord(PlayerPedId(), tankPosition, 5000)
    Citizen.Wait(1000)
    isNozzleInVehicle = false
    vehicleFueling = false
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(PlayerPedId(), "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "pickupnozzle", maxVolume)
    Wait(300)
    ClearPedTasks(PlayerPedId())
    local pos = { x = 0.11, y = 0.02, z = 0.02 }
    local rot = { x = -80.0, y = -90.0, z = 15.0 } 
    AttachEntityToEntity(spawnedNozzle, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x49D9), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
end

function CreateVehicleTarget(vehicle)
    exports['qb-target']:AddTargetEntity(vehicle, {
        options = {{
            name = "set_nozzle_on_vehicle",
            type = "client",
            event = "",
            icon = "fas fa-car",
            label = Lang:t('set_nozzle'),
            action = function(entity)
                isNozzleInVehicle = true
                PutNozzleInVehicle()
            end,
            canInteract = function(entity, distance, data)
                if isNozzleInVehicle then return false end
                return true
            end
        },{
            name = "take_nozzle_from_vehicle",
            type = "client",
            event = "",
            icon = "fas fa-car",
            label = Lang:t('take_nozzle'),
            action = function(entity)
                isNozzleInVehicle = false
                TakeFromVehicle()
            end,
            canInteract = function(entity, distance, data)
                if not isNozzleInVehicle then return false end
                return true
            end
        }},
        distance = 2.0
    })
end

function SpawnPumpHose()
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(PlayerPedId(), pumpHandle, 5000)
    Citizen.Wait(1000)
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(ped, "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "pickupnozzle", maxVolume)
    Wait(300)
    ClearPedTasks(PlayerPedId())
    while not pump do Wait(1) end
    local nozzle = CreateObject('prop_cs_fuel_nozle', 0, 0, 0, true, true, false)
    while not nozzle do Wait(1) end
    AttachEntityToEntity(nozzle, ped, GetPedBoneIndex(ped, 0x49D9), 0.11, 0.02, 0.02, -80.0, -90.0, 15.0, true, true, false, true, 1, true)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(1)
        RopeLoadTextures()
    end
    local rope = AddRope(pump.x, pump.y, pump.z, 0.0, 0.0, 0.0, 3.0, 4, 1000.0, 0.0, 1.0, false, false, false, 1.0, true)
    while not rope do Wait(1) end
    ActivatePhysics(rope)
    Wait(50)
    local nozzlePos = GetEntityCoords(nozzle)
    nozzlePos = GetOffsetFromEntityInWorldCoords(nozzle, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(rope, pumpHandle, nozzle, pump.x, pump.y, pump.z + 2.34, nozzlePos.x, nozzlePos.y, nozzlePos.z, 5.0, false, false, nil, nil)
    spawnedHose = rope
    spawnedNozzle = nozzle
    holdingNozzle = true
    CreateVehicleTarget(lastVehicle)
end

function RemovePumpHose()
    if spawnedHose ~= nil and spawnedNozzle ~= nil then
        TaskTurnPedToFaceEntity(PlayerPedId(), pumpHandle, 5000)
        Citizen.Wait(1000)
        LoadAnimDict("anim@am_hold_up@male")
        TaskPlayAnim(PlayerPedId(), "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
        TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "putbacknozzle", maxVolume)
        Wait(300)
        ClearPedTasks(PlayerPedId())
        RopeUnloadTextures()
        DeleteRope(spawnedHose)
        DeleteEntity(spawnedNozzle)
        spawnedHose = nil
        holdingNozzle = false
    end
end

function DeleteBlips()
    for k, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end

function LoadBlips()
    for k, station in pairs(config.GasStations) do
        if station and station.coords then
            local coords = vector3(station.coords.x, station.coords.y, station.coords.z)
            local blip = AddBlipForCoord(coords)
            SetBlipSprite(blip, station.blip_sprite)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, station.blip_color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(station.company_name)
            EndTextCommandSetBlipName(blip)
            SetBlipAsShortRange(blip, true)
            blips[#blips + 1] = blip
        end
    end

    for k, shop in pairs(config.BuyStationsStores) do
        local blip = AddBlipForCoord(shop.coords)
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, shop.blip.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, true)
        blips[#blips + 1] = blip
    end
end

function GetNearestGasStationId(coords)
    local id = -1
    if config.GasStations ~= nil then
        for k, v in pairs(config.GasStations) do
            local distance = GetDistance(v.coords, coords)
            if distance < 100.0 then id = v.id end
        end
    end
    return id
end

function RefuelWithJerrycan(jerrycanfuelamount)
    local refuelAmount = jerrycanfuelamount
    local refueltimer = config.RefuelTime * tonumber(refuelAmount)
    TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "refuel", maxVolume)
    QBCore.Functions.Progressbar('refuel_gas', Lang:t('refueling_vehicle'), refueltimer, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = "weapon@w_sp_jerrycan",
        anim = "fire",
        flags = 17
    }, {}, {}, function() -- Play When Done
        StopAnimTask(PlayerPedId(), "weapon@w_sp_jerrycan", "fire", 1.0)
        TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "fuelstop", maxVolume)
        Notify("jerry_can_success_vehicle", 'success')
        FreezeEntityPosition(PlayerPedId(), false)
        TriggerServerEvent('mh-fuel:server:removejerryCan')
        SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263, true)
        usingCan = false
        local vehicle = VehicleInFront(PlayerPedId())
        local fuel = GetFuel(vehicle)
        SetFuel(vehicle, fuel + 25.0)
    end, function() -- Play When Cancel
        StopAnimTask(PlayerPedId(), "weapon@w_sp_jerrycan", "fire", 1.0)
        TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "fuelstop", maxVolume)
        Notify("cancelled", 'error')
        SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263, true)
        FreezeEntityPosition(PlayerPedId(), false)
        usingCan = false
    end, "weapon_petrolcan")
end

function BuyJerrycan(price)
    QBCore.Functions.TriggerCallback("mh-fuel:server:HasMoney", function(result)
        if result then
            local id = GetNearestGasStationId(GetEntityCoords(PlayerPedId()))
            TriggerServerEvent('mh-fuel:server:buyjerryCan', id, price)
        end
    end, price)
end

function NearPumpStation(coords)
    local entity = nil
    for hash in pairs(config.PumpModels) do
        entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, hash, true, true, true)
        if entity ~= 0 then break end
    end
    if config.PumpModels[GetEntityModel(entity)] then return GetEntityCoords(entity), entity end
end

function CreateTargetControll(prop)
    exports['qb-target']:AddTargetModel(prop, {
        options = {{
            name = "buy_jerrycan",
            type = "client",
            event = "",
            icon = "fas fa-car",
            label = Lang:t('buy_jerrycan'),
            action = function(entity)
                BuyJerrycan(config.JerrycanPrice)
            end,
            canInteract = function(entity, distance, data)
                if holdingNozzle then return false end
                return true
            end
        }, {
            name = "take_nozzle",
            type = "client",
            event = "",
            icon = "fas fa-car",
            label = Lang:t('take_nozzle'),
            action = function(entity)
                holdingNozzle = true
                SpawnPumpHose()
            end,
            canInteract = function(entity, distance, data)
                if isTankFull then return false end
                if lastVehicle == nil then return false end
                if holdingNozzle then return false end
                return true
            end
        }, {
            name = "return_nozzle",
            type = "client",
            event = "",
            icon = "fas fa-car",
            label = Lang:t('return_nozzle'),
            action = function(entity)
                holdingNozzle = false
                RemovePumpHose()
            end,
            canInteract = function(entity, distance, data)
                if lastVehicle == nil then return false end
                if not holdingNozzle then return false end
                return true
            end
        }},
        distance = 1.5
    })
end

CreateThread(function()
    while true do
        Wait(1000)
        if isLoggedIn and vehicleFueling and DoesEntityExist(lastVehicle) then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local vehicleCoords = GetEntityCoords(lastVehicle)
            if GetDistance(vehicleCoords, pedCoords) > 10 then
                SendNUIMessage({ type = 'setVolume', volume = 0.0 })
            elseif GetDistance(vehicleCoords, pedCoords) > 9 then
                SendNUIMessage({ type = 'setVolume', volume = 0.1 })
            elseif GetDistance(vehicleCoords, pedCoords) > 8 then
                SendNUIMessage({ type = 'setVolume', volume = 0.2 })
            elseif GetDistance(vehicleCoords, pedCoords) > 7 then
                SendNUIMessage({ type = 'setVolume', volume = 0.3 })
            elseif GetDistance(vehicleCoords, pedCoords) > 6 then
                SendNUIMessage({ type = 'setVolume', volume = 0.4 })
            elseif GetDistance(vehicleCoords, pedCoords) > 5 then
                SendNUIMessage({ type = 'setVolume', volume = 0.5 })
            elseif GetDistance(vehicleCoords, pedCoords) < 5 then
                SendNUIMessage({ type = 'setVolume', volume = 5.0 })
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if isLoggedIn then
            if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                    lastVehicle = vehicle
                    local currFuel = GetFuel(vehicle)
                    if currFuel == -1.0 then
                        TriggerServerEvent('mh-fuel:server:registerVehicle', NetworkGetNetworkIdFromEntity(vehicle))
                    elseif IsVehicleEngineOn(vehicle) then
                        -- From LegacyFuel
                        SetFuel(vehicle, currFuel - config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (config.FuelClasses[GetVehicleClass(vehicle)] or 1.0) / 10) 
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        if isLoggedIn then
            local coords = GetEntityCoords(PlayerPedId())
            pump, pumpHandle = NearPumpStation(coords)
            local pumpDistance = GetDistance(coords, pump)
            if (pumpDistance ~= nil and lastVehicle ~= nil) and pumpDistance <= 2.5 and DoesEntityExist(lastVehicle) then
                sleep = 5
                if GetPedInVehicleSeat(lastVehicle, -1) ~= PlayerPedId() then
                    local currentFuel = GetVehicleFuelLevel(lastVehicle)
                    if currentFuel < 100.0 then
                        isTankFull = false
                    elseif currentFuel >= 98.0 then
                        isTankFull = true
                        if config.Use3DTest then
                            Draw3DText(pump.x, pump.y, pump.z + 1.0, Lang:t('tank_is_full'))
                        end
                    end
                end
            end
            if (pump ~= nil and lastVehicle ~= nil and DoesEntityExist(lastVehicle)) then
                if GetPedInVehicleSeat(lastVehicle, -1) == PlayerPedId() then
                    sleep = 5
                    if config.Use3DTest then
                        Draw3DText(pump.x, pump.y, pump.z + 2.0, Lang:t('gasstation'))
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        if isLoggedIn then
            if lastVehicle ~= nil and DoesEntityExist(lastVehicle) then
                if usingCan then
                    while usingCan do
                        local currentFuel = GetFuel(lastVehicle)
                        currentFuel = math.floor(currentFuel + config.PriceTick)
                        if currentFuel < 100 then
                            usingCan = true
                            SetFuel(lastVehicle, currentFuel)
                        elseif currentFuel >= 100 then
                            usingCan = false
                            SetFuel(lastVehicle, currentFuel)
                        end
                    end
                elseif not usingCan then
                    local vehicleClass = GetVehicleClass(lastVehicle)
                    local classMultiplier = config.FuelClasses[vehicleClass]
                    local cost = 0
                    local fuel = nil
                    local done = false
                    while vehicleFueling do
                        cost = cost + math.floor((config.PriceTick / classMultiplier) * config.FuelPrice - math.random(0, 100) / 100)
                        local currentFuel = GetFuel(lastVehicle)
                        if vehicleClass ~= 18 and not config.JobVehicles[PlayerData.job.name][GetEntityModel(lastVehicle)] then
                            if PlayerData.money.cash >= cost then
                                currentFuel = math.floor(currentFuel + config.PriceTick)
                                if currentFuel < 100.0 then
                                    SetFuel(lastVehicle, currentFuel)
                                    fuel = currentFuel
                                elseif currentFuel >= 100.0 then
                                    SetFuel(lastVehicle, currentFuel)
                                    vehicleFueling = false
                                    fuel = currentFuel
                                    done = true
                                end
                            else
                                if currentFuel ~= nil then fuel = currentFuel end
                                Notify(Lang:t('no_cash_to_pay'), "error", 5000)
                                vehicleFueling = false
                                done = true
                            end
                        elseif vehicleClass == 18 or config.JobVehicles[PlayerData.job.name][GetEntityModel(lastVehicle)] then
                            QBCore.Functions.TriggerCallback("mh-fuel:server:companyHasMoney", function(callback)
                                if callback.status then
                                    if callback.cash >= cost then
                                        currentFuel = math.floor(currentFuel + config.PriceTick)
                                        if currentFuel < 100.0 then
                                            SetFuel(lastVehicle, currentFuel)
                                            fuel = currentFuel
                                        elseif currentFuel >= 100.0 then
                                            SetFuel(lastVehicle, currentFuel)
                                            vehicleFueling = false
                                            fuel = currentFuel
                                            done = true
                                        end
                                    else
                                        if currentFuel ~= nil then fuel = currentFuel end
                                        Notify(Lang:t('no_company_money_for_more_fuel'), "error", 5000)
                                        vehicleFueling = false
                                        done = true      
                                    end            
                                end
                            end, {price = cost})
                        end
                        Wait(600)
                    end
                    if done and fuel ~= nil then
                        done = false
                        local stationId = GetNearestGasStationId(GetEntityCoords(PlayerPedId()))
                        TriggerServerEvent("mh-fuel:server:PlayWithinDistance", 5.0, "fuelstop", 1.0)
                        QBCore.Functions.TriggerCallback("mh-fuel:server:payfuel", function(callback)
                            if callback.status then
                                Notify(callback.message, "success", 5000)
                            elseif not callback.status then
                                Notify(callback.message, "error", 5000)
                            end
                        end, {price = cost, fuel = fuel, netid = NetworkGetNetworkIdFromEntity(lastVehicle), stationId = stationId})
                    end 
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn then
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local itemInHand = GetSelectedPedWeapon(ped)
            if itemInHand == 883325847 and not holdingNozzle and not isNozzleInVehicle then
                sleep = 5
                local veh = VehicleInFront(ped)
                if veh then
                    local vehClass = GetVehicleClass(veh)
                    local zPos = config.NozzleBasedOnClass[vehClass + 1]
                    local can = GetAmmoInPedWeapon(ped, 883325847)
                    local distance = 1.5
                    local tankBone, nozzlePosition, textPosition, isBike = GetVehicleFuelBonePosition(veh)
                    local tankPosition = GetWorldPositionOfEntityBone(veh, tankBone)
                    if tankPosition and #(pedCoords - tankPosition) < distance then
                        local fuel = GetFuel(veh)
                        if not usingCan then
                            Draw3DText(tankPosition.x, tankPosition.y, tankPosition.z + zPos, Lang:t('press_to_refuel'))
                        end
                        if IsControlPressed(0, 51) and not usingCan then
                            usingCan = true
                            RefuelWithJerrycan(25)
                        end
                    end
                end
            else
                sleep = 500
            end
        end
        Wait(sleep)
    end
end)
