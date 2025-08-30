<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
    <a href="https://github.com/MaDHouSe79/mh-fuel/issues">
        <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-fuel"/>  </a>
    <a href="https://github.com/MaDHouSe79/mh-fuel/watchers">
        <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-fuel"/> 
    </a> 
    <a href="https://github.com/MaDHouSe79/mh-fuel/network/members">
        <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-fuel"/> 
    </a>  
    <a href="https://github.com/MaDHouSe79/mh-fuel/stargazers">
        <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-fuel?color=white"/> 
    </a>
    <a href="https://github.com/MaDHouSe79/mh-fuel/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/MaDHouSe79/mh-fuel?color=black"/> 
    </a>      
</p>

<p align="center">
    <img alig src="https://github-profile-trophy.vercel.app/?username=MaDHouSe79&margin-w=15&column=6" />
</p>

# MH Fuel for QB-Core - (OneSync Required) (BETA Version)
- A fuel script with a fuel station as job and shop build in that sync fuel between all players.

# Company vehicles
- if a vehicle class is an Emergency class 18 vehicle, this fuel will be paid by the company.
- you can also add more company vehicles in the config `Config.JobFuelPaidByCompany` table.
- With this people don't have to pay from there own money.

# Owned Fuel Stations
- You can use owned fuel stations, but you can also use the fuel system only and not the owned fuel stations.
- Don't forget to add the database or the station job does not work.
- You need to change `Config.StationsCanBeOwnedByPlayers` from `false` to `true`.

# Shop Items
- You need to add the item in de `server/stations.lua` file in the `ShopItems` table at line 4.
- when you add new items you need to set `SV_Config.RunDatabaseBackupLoader` from `false` to `true` 
- when you start the server or script, after that you need to set `SV_Config.RunDatabaseBackupLoader` to `false` again.
- This will reset the database gasstations and items.
  
# Dependencies
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- [ox_lib](https://github.com/overextended/ox_lib/releases)
- [PolyZone](https://github.com/mkafrin/PolyZone/releases)
- [progressbar](https://github.com/qbcore-framework/progressbar)
- [qb-target](https://github.com/qbcore-framework/qb-target)

# Install
- Add the `database.sql` to your fivem server database.
- Create a folder in `resources` and name it `[mh]`.
- Unzip mh-fuel and go inside that folder, you see a folder `mh-fuel-main`, rename that folder to `mh-fuel`.
- Place the folder `mh-fuel` inside `[mh]` folder.
- Add `ensure [mh]` in `server.cfg` below `ensure [defaultmaps]`.

# ox_target, if you want to use ox_target 
- You need to remove `qb-target` from the `[qb]` folder.

# Exports Client side
```lua
exports['mh-fuel']:SetFuel(vehicle, fuel) -- set fuel
exports['mh-fuel']:GetFuel(vehicle) -- get fuel
```

# Admin Commands
- /setfuel [player_id] [amount] (the player id must be the driver)
- /fixvehicle [player_id] (the player id must be the driver)

# You need to replace code in you server as below.
- Replace from `exports['LegacyFuel']` to `exports['mh-fuel']`

# Language NOTE
- I would really appreciate it if people added more languages,
- so more servers can use this script in there own language.

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
