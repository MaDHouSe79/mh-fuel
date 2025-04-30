--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --
SV_Config = {}

SV_Config.Locale = "en"

-- Cash detection
SV_Config.MoneySign = "€" -- (€/$)
SV_Config.MoneyType = "cash"

SV_Config.UseTarget = false
SV_Config.Target = 'qb-target'

SV_Config.EnableNotify = true
SV_Config.NotifyTitle = "MH Gas Station"

SV_Config.Use3DTest = false

-- Vehiclekey triggers
SV_Config.IsTriggerServerSide = true
SV_Config.VehicleKeyTrigger = "qb-vehiclekeys:server:AcquireVehicleKeys"

SV_Config.BaseImagesFolder = 'nui://qb-inventory/html/images'

SV_Config.InteractTxt = "E"
SV_Config.InterActButton = 38 -- E

SV_Config.RefuelTime = 600
SV_Config.JerrycanPrice = 500
SV_Config.FuelPrice = 2
SV_Config.PriceTick = 2

-- true if you want players to own a gas station.
SV_Config.StationsCanBeOwnedByPlayers = true 
-- true if you want players to own gas station shop.
SV_Config.StationShopsCanBeOwnedByPlayers = true 

--[[ Job Vehicle To Get And Reload Fuel for gasstation owners ]] --
SV_Config.DeliverVehicle = "packer"
SV_Config.DeliverTrailer = "tanker2"
SV_Config.TrailerMaxCapacity = 1000.0

-- Job Type Fuel Paid By Company (new qb)
SV_Config.JobTypeFuelPaidByCompany = {
    ['leo'] = true,
    ['ems'] = true,
    ['mechanic'] = true,
    -- you can add more types
}

-- Job Fuel Paid By Company (old qb)
SV_Config.JobFuelPaidByCompany = {
    ['police'] = true,
    ['ambulance'] = true,
    ['mechanic'] = true,
    -- you can add more jobs
}

-- Job Vehicles, this are vehicles that are allowed to pay by the company.
SV_Config.JobVehicles = {
    ['police'] = { -- job
        [2046537925] = true,  -- police
        [-1627000575] = true, -- police2
        [1912215274] = true   -- police3
    },
    ['ambulance'] = { -- job
        [1171614426] = true,  -- ambulance
    },
    ['mechanic'] = { -- job
        [-442313018] = true,  -- towtruck
        [-1323100960] = true, -- towtruck2
        [1353720154] = true,  -- flatbed
    },
    -- add more job vehicles
}

SV_Config.PumpModels = {
    [-2007231801] = true,
    [1339433404] = true,
    [1694452750] = true,
    [1933174915] = true,
    [-462817101] = true,
    [-469694731] = true,
    [-164877493] = true
}

SV_Config.NozzleBasedOnClass = {
    0.65, -- Compacts
    0.65, -- Sedans
    0.85, -- SUVs
    0.6, -- Coupes
    0.55, -- Muscle
    0.6, -- Sports Classics
    0.6, -- Sports
    0.53, -- Super
    0.12, -- Motorcycles
    0.8, -- Off-road
    0.7, -- Industrial
    0.6, -- Utility
    0.7, -- Vans
    0.0, -- Cycles
    0.0, -- Boats
    0.0, -- Helicopters
    0.0, -- Planes
    0.6, -- Service
    0.65, -- Emergency
    0.65, -- Military
    0.75, -- Commercial
    0.0 -- Trains
}

SV_Config.FuelClasses = {
    [0] = 1.0, -- Compacts
    [1] = 1.0, -- Sedans
    [2] = 0.8, -- SUVs
    [3] = 1.2, -- Coupes
    [4] = 1.1, -- Muscle
    [5] = 1.3, -- Sports Classics
    [6] = 1.2, -- Sports
    [7] = 1.2, -- Super
    [8] = 0.8, -- Motorcycles
    [9] = 1.0, -- Off-road
    [10] = 0.8, -- Industrial
    [11] = 0.8, -- Utility
    [12] = 0.8, -- Vans
    [13] = 0.0, -- Cycles
    [14] = 1.0, -- Boats
    [15] = 1.0, -- Helicopters
    [16] = 1.0, -- Planes
    [17] = 1.2, -- Service
    [18] = 1.2, -- Emergency
    [19] = 1.2, -- Military
    [20] = 1.2, -- Commercial
    [21] = 1.0 -- Trains
}

SV_Config.FuelUsage = {
    [1.0] = 0.4,
    [0.9] = 0.4,
    [0.8] = 0.3,
    [0.7] = 0.3,
    [0.6] = 0.2,
    [0.5] = 0.2,
    [0.4] = 0.1,
    [0.3] = 0.1,
    [0.2] = 0.1,
    [0.1] = 0.1,
    [0.0] = 0.0
}

-- find more https://fontawesome.com/
SV_Config.Fontawesome = {
    boss = "fa-solid fa-people-roof",
    pump = "fa-solid fa-gas-pump",
    trucks = "fa-solid fa-truck",
    trailers = "fa-solid fa-trailer",
    garage = "fa-solid fa-warehouse",
    goback = "fa-solid fa-backward-step",
    shop = "fa-solid fa-basket-shopping",
    buy = "fa-solid fa-cash-register",
    stop = "fa-solid fa-stop",
    store = "fa-solid fa-store",
}

------------------------------------------------------------
-- Stations Stuff

SV_Config.GasStations = {} -- do not edit or remove this.
SV_Config.ShopItems = {}   -- do not edit or remove this.

-- Buy Stations Stores  
SV_Config.BuyStationsStores = {
    { -- cityhall
        name = "Gasstation Store",
        ped = "mp_g_m_pros_01",
        coords = vector4(-266.3482, -966.6049, 31.2240, 246.2112),
        blip = {
            id = nil,
            label = "Buy Gastations",
            sprite = 375,
            color = 44
        }
    }, -- you can add more locations
}

-- Load points Settings
SV_Config.LoadPointProp = "prop_oil_wellhead_05"
SV_Config.LoadPointBlipSprite = 467
SV_Config.LoadPointBlipColor = 21
SV_Config.LoadPointBlipScale = 0.8
SV_Config.LoadPointTankProp = "prop_storagetank_05"
SV_Config.LoadPoints = { 
    { -- city
        hasTank = false, -- if try only a oil_wellhead will spawn
        tankProp = SV_Config.LoadPointTankProp,
        tankCoords = vector4(1482.0576, -2437.6223, 65.5, 82.3474),
        prop = SV_Config.LoadPointProp,
        coords = vector4(1482.8029, -2431.4448, 74.1822, 357.6255),
        entity = nil,
        blip = {
            id = nil,
            label = Lang:t('fuel_load_point'),
            sprite = SV_Config.LoadPointBlipSprite,
            color = SV_Config.LoadPointBlipColor,
            scale = SV_Config.LoadPointBlipScale
        }
    },
    { --- north
        hasTank = false,
        tankProp = SV_Config.LoadPointTankProp,
        tankCoords = vector4(531.3108, 2990.8425, 39.5, 326.1268),
        prop = SV_Config.LoadPointProp,
        coords = vector4(534.9765, 2996.2473, 47.0, 332.4698),
        entity = nil,
        blip = {
            id = nil,
            label = Lang:t('fuel_load_point'),
            sprite = SV_Config.LoadPointBlipSprite,
            color = SV_Config.LoadPointBlipColor,
            scale = SV_Config.LoadPointBlipScale
        }
    },
}


SV_Config.CreateFuel = {
    vehicle = {model="tanker2", load_capacity = 500},
    props = {"p_oil_pjack_01_s", "p_oil_pjack_03_s", "p_oil_pjack_02_amo", "p_oil_pjack_03_amo", "p_oil_pjack_01_amo"},
    pumpoil = {
        timer = 100,
        neededitem = 'emptyoilbarrel',
        rewarditem = 'oilbarrel',
        capacity = 50,
        amount = 1
    },

    neededItems = {
        {item = "oilbarrel", amount = 1},
        {item = "hide", amount = 5}, 
    },
}

------------------------------------------------------------
-- Only use this true 1 time is you load the server.
-- This wil reset the coords and items for the gasstations.
SV_Config.RunDatabaseBackupLoader = false
------------------------------------------------------------