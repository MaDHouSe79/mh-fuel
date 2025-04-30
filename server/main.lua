--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()

local function UpdateStationData(id, data)
    if GasStations[id] then
        GasStations[id].id = data.id
        GasStations[id].citizenid = data.citizenid
        GasStations[id].username = data.username
        GasStations[id].company_name = data.company_name
        GasStations[id].company_money = data.company_money
        GasStations[id].blip_sprite = data.blip_sprite
        GasStations[id].blip_color = data.blip_color
        GasStations[id].current_capacity = data.current_capacity
        GasStations[id].max_capacity = data.max_capacity
        GasStations[id].fuel_price = data.fuel_price
        GasStations[id].buy_price = data.buy_price
        GasStations[id].items = json.decode(data.items)
        GasStations[id].hasMLO = data.hasmlo
    end
end

local function RefreshStationData()
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do UpdateStationData(v.id, v) end
    end)
end

local function ReloadAllStations()
    RefreshStationData()
    TriggerClientEvent('mh-fuel:client:refreshStations', -1, GasStations)
end

local function AddComapnyMoney(src, station_id, amount, display)
    if display == nil then display = true end
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do
            if v.id == station_id then
                local Player = QBCore.Functions.GetPlayer(src)
                if v.citizenid == Player.PlayerData.citizenid then
                    MySQL.Async.execute('UPDATE player_gasstation SET company_money = company_money + ? WHERE id = ?', {amount, station_id})
                    if display then TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('added_money_to_account', {amount=SV_Config.MoneySign..amount}), "success") end
                    ReloadAllStations()
                end
            end
        end
    end)
end

local function TakeComapnyMoney(src, station_id, amount, display)
    if display == nil then display = true end
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do
            if v.id == station_id then
                local Player = QBCore.Functions.GetPlayer(src)
                if v.citizenid == Player.PlayerData.citizenid then
                    if v.company_money >= amount then
                        MySQL.Async.execute('UPDATE player_gasstation SET company_money = company_money - ? WHERE id = ?', {amount, station_id})
                        if display then TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('taked_money_from_account', {amount=SV_Config.MoneySign..amount}), "success") end
                        ReloadAllStations()
                    elseif v.company_money <= 0 then
                        MySQL.Async.execute('UPDATE player_gasstation SET company_money = ? WHERE id = ?', {0, station_id})
                        TriggerClientEvent('mh-fuel:client:stopFuellingTrailer', src)
                    end
                end
            end
        end
    end)
end

local function UpdateShopData(src, station_id, item, amount, price, type)
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        local items = {}
        for _, v in pairs(rs) do
            if v.id == station_id then
                items = json.decode(v.items)
                if items then
                    for _, d in pairs(items) do
                        if d.name == item.name then
                            if type == "add" then
                                TakeComapnyMoney(src, station_id, price / 2, false)
                                d.amount = d.amount + amount
                            elseif type == "remove" then
                                AddComapnyMoney(src, station_id, price, false)
                                d.amount = d.amount - amount
                            end
                        end
                    end
                end
            end
        end
        MySQL.Async.execute('UPDATE player_gasstation SET items = ? WHERE id = ?', {json.encode(items), station_id})
    end)
end

local function RemoveFuel(station_id, amount)
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do
            if v.id == station_id then
                MySQL.Async.execute('UPDATE player_gasstation SET current_capacity = current_capacity - ? WHERE id = ?', {amount, station_id})
                RefreshStationData()
            end
        end
    end)
end

local function AddFuel(src, station_id, amount)
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do
            if v.id == station_id then
                local toadd = tonumber(v.current_capacity) + tonumber(amount)
                if tonumber(toadd) <= tonumber(v.max_capacity) then
                    MySQL.Async.execute('UPDATE player_gasstation SET current_capacity = current_capacity + ? WHERE id = ?', {amount, station_id})
                else
                    TriggerClientEvent('mh-fuel:client:stopFuellingStation', src)
                end
                RefreshStationData()
            end
        end
    end)
end

local function PayFuel(station_id, price)
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do
            if v.citizenid ~= 'none' and v.id == station_id then
                MySQL.Async.execute('UPDATE player_gasstation SET company_money = company_money + ? WHERE id = ?', {price, station_id})
                RefreshStationData()
            end
        end
    end)
end

QBCore.Functions.CreateCallback('mh-fuel:server:GetStationData', function(source, cb, id)
    local src = source
    ReloadAllStations()
    cb(GasStations[id])
end)

QBCore.Functions.CreateCallback('mh-fuel:server:GetAllStations', function(source, cb)
    ReloadAllStations()
    cb(GasStations)
end)

QBCore.Functions.CreateCallback('mh-fuel:server:IsGasStationOwner', function(source, cb, id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
            for k, station in pairs(rs) do
                if station.citizenid == Player.PlayerData.citizenid then
                    cb({isOwner = true, data = station})
                    return
                end
            end
            cb({isOwner = false, data = nil})
            return
        end)
    else
        cb({isOwner = false, data = nil})
        return
    end
end)

QBCore.Functions.CreateCallback('mh-fuel:server:HasMoney', function(source, cb, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if (Player.Functions.GetMoney(SV_Config.MoneyType) >= price or Player.Functions.GetMoney('bank') >= price) then
            cb(true)
            return
        else
            cb(false)
            return
        end
    else
        cb(false)
        return
    end
end)

QBCore.Functions.CreateCallback("mh-fuel:server:companyHasMoney", function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = {status = false, amount = 0}
    if Player then
        local account = exports['qb-banking']:GetAccountBalance(Player.PlayerData.job.name)
        result = {status = true, cash = account}
    end
    cb(result)
end)

QBCore.Functions.CreateCallback("mh-fuel:server:payfuel", function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = math.floor(data.price)
    if Player then
        local vehicle = NetworkGetEntityFromNetworkId(data.netid)
        if ((SV_Config.JobFuelPaidByCompany[Player.PlayerData.job.name]) or (SV_Config.JobTypeFuelPaidByCompany[Player.PlayerData.job.type])) and Player.PlayerData.job.onduty then
            local account = exports['qb-banking']:GetAccountBalance(Player.PlayerData.job.name)
            if account >= amount then
                if exports['qb-banking']:RemoveMoney(Player.PlayerData.job.name, amount) then
                    PayFuel(data.stationId, amount)
                    if vehicle ~= 0 and DoesEntityExist(vehicle) then Entity(vehicle).state.fuel = data.fuel + 0.0 end
                    ReloadAllStations()
                    cb({paid = true, message = Lang:t('fuel_paid_by_company', {company = Player.PlayerData.job.name})})
                    return
                else
                    cb({paid = false, message = Lang:t('no_company_money_for_more_fuel')})
                    return
                end
            else
                cb({paid = false, message = Lang:t('no_company_money_for_more_fuel')})
                return
            end
        else
            if Player.Functions.GetMoney(SV_Config.MoneyType) >= amount then
                if Player.Functions.RemoveMoney(SV_Config.MoneyType, amount, "fuel-paid") then
                    PayFuel(data.stationId, amount)
                    if vehicle ~= 0 and DoesEntityExist(vehicle) then Entity(vehicle).state.fuel = data.fuel + 0.0 end
                    ReloadAllStations()
                    cb({paid = true, message = "Fuel is paid"})
                    return
                else
                    cb({paid = false, message = Lang:t('no_money_for_more_fuel')})
                    return
                end
            else
                cb({paid = false, message = Lang:t('no_money_for_more_fuel')})
                return
            end
        end
    end
end)

QBCore.Functions.CreateCallback("mh-fuel:server:HasMoney", function(source, cb, station_id, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local result = MySQL.Sync.fetchAll("SELECT * FROM player_gasstation AND id = ?", {station_id})[1]
        if result.id == station_id and result.company_money >= amount then
            return true
        end
    end
    return false
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        ReloadAllStations()
        StopResource('LegacyFuel')
    end
end)

RegisterNetEvent('mh-fuel:server:setVehicleFuel', function(netid, amount)
	local entity = NetworkGetEntityFromNetworkId(netid)
	if entity ~= 0 then Entity(entity).state.fuel = amount + 0.0 end
end)

RegisterNetEvent("mh-fuel:server:SellStation", function(station_id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = MySQL.Sync.fetchScalar('SELECT buy_price FROM player_gasstation WHERE id = ? LIMIT 1', {station_id})
    MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
        for k, v in pairs(rs) do
            if v.id == station_id then
                if v.citizenid == Player.PlayerData.citizenid then
                    MySQL.Async.execute('UPDATE player_gasstation SET citizenid = ?, username = ?, company_name = ?, company_money = ?, current_capacity = ?, blip_sprite = ?, blip_color = ? WHERE id = ?', {'none', 'none', "Gas Station", 0, 0, 415, 0, station_id})
                    QBCore.Functions.AddMoney(src, 'bank', price)
                    ReloadAllStations()
                    TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('selled_your_gasstation', {id=station_id}), "success")
                else
                    TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('not_own_the_gasstation', {id=station_id}), "error")
                end
            end
        end
    end)
end)

RegisterNetEvent("mh-fuel:server:BuyStation", function(station_id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        local price = MySQL.Sync.fetchScalar('SELECT buy_price FROM player_gasstation WHERE id = ? LIMIT 1', {station_id})
        if Player.Functions.GetMoney(SV_Config.MoneyType) >= price then
            MySQL.Async.fetchAll("SELECT * FROM player_gasstation", {}, function(rs)
                for k, v in pairs(rs) do
                    if v.id == station_id then
                        if v.citizenid == "none" and v.username == "none" then
                            if Player.Functions.RemoveMoney(SV_Config.MoneyType, price, "buy-gasstation") then
                                local username = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
                                MySQL.Async.execute('UPDATE player_gasstation SET citizenid = ?, username = ? WHERE id = ?', {citizenid, username, station_id})
                                ReloadAllStations()
                                TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('you_just_buy_a_gasstation', {id=station_id}), "success")
                            else
                                TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('no_money'), "error")
                            end
                        elseif v.citizenid ~= "none" and v.usermame ~= "none" then
                            TriggerClientEvent('mh-fuel:client:notify', src, "This station is already owned..", "error")
                        end
                    end
                end
            end)
        else
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('no_money'), "error")
        end
    end
end)

RegisterNetEvent("mh-fuel:server:ChangeStationName", function(station_id, company_name)
    local src = source
    if GasStations[station_id].id == station_id then
        local Player = QBCore.Functions.GetPlayer(src)
        if GasStations[station_id].citizenid == Player.PlayerData.citizenid then
            MySQL.Async.execute('UPDATE player_gasstation SET company_name = ? WHERE id = ?', {company_name, station_id})
            ReloadAllStations()
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('company_name_has_change', {name=company_name}), "success")
        else
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('not_own_the_gasstation', {id=station_id}), "error")
        end
    end
end)

RegisterNetEvent("mh-fuel:server:ChangeStationColor", function(station_id, blip_color)
    local src = source
    if GasStations[station_id].id == station_id then
        local Player = QBCore.Functions.GetPlayer(src)
        if GasStations[station_id].citizenid == Player.PlayerData.citizenid then
            MySQL.Async.execute('UPDATE player_gasstation SET blip_color = ? WHERE id = ?', {blip_color, station_id})
            ReloadAllStations()
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('company_color_has_change', {color=blip_color}), "success")
        else
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('not_own_the_gasstation', {id=station_id}), "error")
        end
    end
end)

RegisterNetEvent("mh-fuel:server:ChangeStationFuelPrice", function(station_id, price)
    local src = source
    if GasStations[station_id].id == station_id then
        local Player = QBCore.Functions.GetPlayer(src)
        if GasStations[station_id].citizenid == Player.PlayerData.citizenid then
            MySQL.Async.execute('UPDATE player_gasstation SET fuel_price = ? WHERE id = ?', {price, station_id})
            ReloadAllStations()
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('company_price_has_change', {price=price}), "success")
        else
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('not_own_the_gasstation', {id=station_id}), "error")
        end
    end
end)

RegisterNetEvent("mh-fuel:server:BuyStationFuel", function(station_id, amount)
    local src = source
    if GasStations[station_id].id == station_id then
        local Player = QBCore.Functions.GetPlayer(src)
        local job = Player.PlayerData.job.name
        local price = amount / 2
        if (Player.Functions.GetMoney(SV_Config.MoneyType) >= price or Player.Functions.GetMoney('bank') >= price) then
            if GasStations[station_id].citizenid == Player.PlayerData.citizenid then
                MySQL.Async.execute('UPDATE player_gasstation SET current_capacity = current_capacity + ? WHERE id = ?', {amount, station_id})
                ReloadAllStations()
                TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('just_buy_liters', {amount=amount}), "success")
            end
        else
            TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('no_money'), "error")
        end
    end
end)

RegisterNetEvent('mh-fuel:server:RemoveFuelFromTank', function(station_id, amount)
    local src = source
    RemoveFuel(station_id, amount)
end)

RegisterNetEvent('mh-fuel:server:AddFuelToTank', function(station_id, amount)
    local src = source
    AddFuel(src, station_id, amount)
end)

RegisterNetEvent('mh-fuel:server:AddMoney', function(station_id, amount, display)
    local src = source
    AddComapnyMoney(src, station_id, amount, display)
end)

RegisterNetEvent('mh-fuel:server:TakeMoney', function(station_id, amount, display)
    local src = source
    TakeComapnyMoney(src, station_id, amount, display)
end)

RegisterNetEvent("mh-fuel:server:onjoin", function()
    local src = source
    ReloadAllStations()
    SV_Config.ShopItems = ShopItems
    SV_Config.GasStations = GasStations
    TriggerClientEvent('mh-fuel:client:onjoin', src, SV_Config)
end)

RegisterNetEvent('mh-fuel:server:registerVehicle', function(netid)
    local entity = NetworkGetEntityFromNetworkId(netid)
    if entity ~= 0 then Entity(entity).state.fuel = math.random(40, 60) end
end)

RegisterNetEvent("mh-fuel:server:buyjerryCan", function(station_id, price)
    local src = source
    if QBCore.Functions.RemoveMoney(src, SV_Config.MoneySign, price) then
        QBCore.Functions.AddItem(src, "weapon_petrolcan", 1)
        RemoveFuel(station_id, 25)
        ReloadAllStations()
        TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('paid_for_jerrycan', {price=SV_Config.MoneySign .. math.floor(price)}), "success")
    else
        TriggerClientEvent('mh-fuel:client:notify', src, Lang:t('no_money'), "error")
    end
end)

RegisterNetEvent("mh-fuel:server:removejerryCan", function()
    local src = source
    QBCore.Functions.RemoveItem(src, "weapon_petrolcan", 1)
end)

RegisterNetEvent("mh-fuel:server:RefreshStations", function()
    ReloadAllStations()
end)

RegisterNetEvent('mh-fuel:server:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    local src = source
    local DistanceLimit = 300
    if maxDistance < DistanceLimit then
        TriggerClientEvent('mh-fuel:client:PlayWithinDistance', -1, GetEntityCoords(GetPlayerPed(src)), maxDistance, soundFile, soundVolume)
    else
        print(('[sound] [^3WARNING^7] %s attempted to trigger mh-fuel:server:PlayWithinDistance over the distance limit ' .. DistanceLimit):format(GetPlayerName(src)))
    end
end)

RegisterNetEvent("mh-fuel:server:BuyItemForShop", function(station_id, item, amount, price)
    local src = source
    UpdateShopData(src, station_id, item, amount, price, "add")
end)

RegisterNetEvent("mh-fuel:server:opentrailerstorage", function(plate)
    local src = source
    exports['qb-inventory']:OpenInventory(src, "stash-trailer-"..plate, {slots = 200, maxweight = 50000000})
end)

RegisterServerEvent('mh-fuel:server:syncAttachEntitiesToRope', function(connecction1_netid, connecction2_netid)
    TriggerClientEvent("mh-fuel:client:syncAttachEntitiesToRope", -1, connecction1_netid, connecction2_netid)
end)

RegisterServerEvent('mh-fuel:server:syncDetachEntitiesToRope', function(rope, connecction1_netid, connecction2_netid)
    TriggerClientEvent("mh-fuel:client:syncDetachEntitiesToRope", -1, rope, connecction1_netid, connecction2_netid)
end)

QBCore.Commands.Add('setfuel', "Set Fuel [id] [amount]", {}, false, function(source, args)
    local src = source
    local playerId = tonumber(args[1])
    local amount = tonumber(args[2])
    local ped = GetPlayerPed(playerId)
    local pedVehicle = GetVehiclePedIsIn(ped, false)
    if not pedVehicle or GetPedInVehicleSeat(pedVehicle, -1) ~= ped then
        return TriggerClientEvent('mh-fuel:client:notify', playerId, 'Player is not in a vehicle')
    end
    if src ~= playerId then
        TriggerClientEvent("mh-fuel:client:setFuel", playerId, amount)
        TriggerClientEvent('mh-fuel:client:notify', playerId, Lang:t("get_fuel_by_admin", {amount=amount}), "success")
    elseif src == playerId then
        TriggerClientEvent("mh-fuel:client:setFuel", src, amount)
        TriggerClientEvent('mh-fuel:client:notify', src, Lang:t("get_fuel_yourself", {amount=amount}), "success")
    end
end, 'admin')

QBCore.Commands.Add('fixvehicle', "fixvehicle [id]", {}, false, function(source, args)
    local src = source
    local playerId = tonumber(args[1])
    local ped = GetPlayerPed(playerId)
    local pedVehicle = GetVehiclePedIsIn(ped, false)
    if not pedVehicle or GetPedInVehicleSeat(pedVehicle, -1) ~= ped then
        return TriggerClientEvent('mh-fuel:client:notify', Lang:t('player_not_in_vehicle'))
    end
    if src ~= playerId then
        TriggerClientEvent("mh-fuel:client:fixVehicle", playerId)
    elseif src == playerId then
        TriggerClientEvent("mh-fuel:client:fixVehicle", src)
    end
end, 'admin')

QBCore.Commands.Add('spawnloadpoint', "Spawn [id]", {}, false, function(source, args)
    local src = source
    local loadpoint = tonumber(args[1])
    if SV_Config.LoadPoints[loadpoint] then
        TriggerClientEvent('mh-fuel:client:spawnlaodpoint', src, SV_Config.LoadPoints[loadpoint])
    end
end, 'admin')

CreateThread(function()
    if GetCurrentResourceName() ~= 'mh-fuel' then
        while true do
            Wait(100)
            print("Please don't rename the script (" .. GetCurrentResourceName() .. "), rename it back to 'mh-fuel'")
        end
    end
end)

------------------------------------------------------------------------------------------------------
--- Databases Backup Loader, if your database data is not good, then use this.
function DatabasesBackUpLoader() -- only use this if you know what you are doeing..
    for station_id, station in pairs(GasStations) do
        MySQL.Async.execute('UPDATE player_gasstation SET items = ? WHERE id = ?', {'', station_id})
        Wait(100)
        MySQL.Async.execute('UPDATE player_gasstation SET items = ? WHERE id = ?', {json.encode(ShopItems), station_id})
    end
    print("[mh-fuelstations] - database backup is successfully loader...")
end
if SV_Config.RunDatabaseBackupLoader then DatabasesBackUpLoader() end -- only use this if you know what you are doeing..
------------------------------------------------------------------------------------------------------