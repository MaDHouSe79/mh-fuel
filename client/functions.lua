--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --
QBCore = exports['qb-core']:GetCoreObject()
config, isLoggedIn, isNozzleInVehicle, usingCan, isFuelingTrailer, isFuelingStation = nil, false, false, false, false, false
spawnedHose, holdingNozzle, spawnedNozzle, lastVehicle, tankBone, currentFuel = nil, false, nil, nil, nil, 0.0
pump, rope, pumpHandle, pumpDistance, currentCost, trailerfuel, currentJobId = nil, nil, nil, nil, 0, 0, -1
spawnedPipe, loadpointBlip, spawnedPumpPipe, spawnedHoseConnection, spawnedPumpPipe = nil, nil, nil, nil, nil
isInPedZone, isInShopZone, isTankFull, vehicleFueling, maxVolume, zoneId = false, false, false, false, 5.0, -1
tankEntity, trailerEntity, currentTrailer, currentTruck, currentTruckPlate, currentTrailerPlate = nil, nil, nil, nil, nil, nil
nozzlePosition, textPosition, loadBlip, isAttach, disableControll = nil, nil, nil, false, false
PlayerData, blips, props, peds, tanks, ropes, stationZones, shopZone = {}, {}, {}, {}, {}, {}, {}, {}

function Notify(message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify({title = "MH Fuel", description = message, type = type})
    else
        QBCore.Functions.Notify({text = "MH Fuel", caption = message}, type, length)
    end
end

function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format(string.strsplit('.', exportName, 2)), function(cb)
        cb(func or function() error(("export '%s' is not supported when using mh-fuel"):format(exportName)) end)
    end)
end

function SetFuel(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    if fuel < 0 then fuel = 0 end
    if fuel > 100 then fuel = 100 end
    NetworkRequestControlOfEntity(vehicle)
    Entity(vehicle).state:set('fuel', fuel + 0.0, true)
    SetVehicleFuelLevel(vehicle, fuel + 0.0)
end

function GetFuel(vehicle)
    if not DoesEntityExist(vehicle) then return end
    return Entity(vehicle).state.fuel or -1.0
end

function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end
    end
end

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(1) end
    end
end

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function DrawText3D(text)
    exports['qb-core']:DrawText(text)
end

function HideText()
    exports['qb-core']:HideText()
end

function CalculateNonLinearAmount(num, power)
    local scaledRandom = math.random() ^ power
    local adjustedValue = scaledRandom * num
    return math.floor(num + adjustedValue)
end

function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function GetPlate(vehicle)
    if vehicle == nil then return nil end
    if not DoesEntityExist(vehicle) then return nil end
    return Trim(GetVehicleNumberPlateText(vehicle))
end

function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

function GetDistance(pos1, pos2)
    if pos1 ~= nil and pos2 ~= nil then
        return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
    end
end

function GetStreetNametAtCoords(coords)
    local streetname1, streetname2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return {main = GetStreetNameFromHashKey(streetname1), cross = GetStreetNameFromHashKey(streetname2)}
end

function GetPumpModel()
    if config ~= nil then
        for k, v in pairs(config.PumpModels) do
            if type(k) == 'string' then
                CreateTargetControll(GetHashKey(k))
            elseif type(k) == 'number' then
                CreateTargetControll(k)
            end
        end
    end
end

function GiveVehicleKeyToPlayer(vehicle, plate)
    if config ~= nil then
        if GetResourceState("es_extended") ~= 'missing' then
            if config.IsTriggerServerSide then
                TriggerServerEvent(config.VehicleKeyTrigger, plate)
            else
                TriggerEvent(config.VehicleKeyTrigger, plate)
            end
        elseif GetResourceState("qb-core") ~= 'missing' then
            if GetResourceState("qb-vehiclekeys") ~= 'missing' then
                if config.IsTriggerServerSide then
                    TriggerServerEvent(config.VehicleKeyTrigger, plate)
                else
                    TriggerEvent(config.VehicleKeyTrigger, plate)
                end
            end
        else
            if config.IsTriggerServerSide then
                TriggerServerEvent(config.VehicleKeyTrigger, plate)
            else
                TriggerEvent(config.VehicleKeyTrigger, plate)
            end
        end
    end
end

function VehicleInFront(ped)
    local entity = nil
    local coords = GetEntityCoords(ped)
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(coords.x, coords.y, coords.z - 1.3, offset.x, offset.y, offset.z, 10, ped, 0)
    local _, _, _, _, entity = GetRaycastResult(rayHandle)
    if IsEntityAVehicle(entity) then
        lastVehicle = entity
        return entity
    end
end

function GetClosestVehicle(coords)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

local missionBlip = nil
function CreateMissionBlip(coords)
	missionBlip = AddBlipForCoord(coords)
	SetBlipSprite(missionBlip, 478)
	SetBlipColour(missionBlip, 5)
    SetBlipScale(missionBlip, 0.5)
	SetBlipAsShortRange(missionBlip, false)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Load Point")
	EndTextCommandSetBlipName(missionBlip)
	SetBlipRoute(missionBlip, 1)
	return missionBlip
end

function DeleteMissionBlip()
    if DoesBlipExist(missionBlip) then
        RemoveBlip(missionBlip)
    end
end

-- exports
exports('SetFuel', SetFuel)
exports('GetFuel', GetFuel)
exportHandler('LegacyFuel.SetFuel', function(vehicle, fuel) SetFuel(vehicle, fuel) end)
exportHandler('LegacyFuel.GetFuel', function(vehicle) return GetFuel(vehicle) end)
