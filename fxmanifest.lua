--[[ ===================================================== ]] --
--[[          MH Fuel System Script by MaDHouSe79          ]] --
--[[ ===================================================== ]] --
fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe79'
description 'MH Fuel - fuel is sycned between all clients.'
version '1.0.0'
lua54 'yes'
repository 'https://github.com/MaDHouSe79/mh-fuel'

ui_page "html/index.html"

files {
    'html/index.html',
    'html/assets/js/*.js',
    'html/assets/css/*.css',
    'html/assets/images/*.png',
    'html/assets/images/shop/*.png',
    'html/assets/sounds/*.ogg',
}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/functions.lua',
    'client/main.lua',
    'client/refuel.lua',
    'client/job.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/stations.lua',
    'server/sv_config.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {
    'oxmysql',
    'PolyZone',
    'ox_lib',
}