fx_version 'adamant'
game 'gta5'

name "Edwin-SAFEZONE"
description "Fivem sunucularınız için safezone!"
author "Edwincik"

dependencies {
    'PolyZone'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    '@PolyZone/EntityZone.lua',
    'config.lua',
    'client/*.lua'
}