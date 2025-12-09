fx_version 'cerulean'
game 'gta5'

author 'AMA Framework'
description 'Framework FiveM moderne et optimisé'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/functions.lua',
    'shared/serialization.lua',
    'shared/ama_run.lua',
    'shared/ama_discord.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/ama_done.lua',
    'server/ama_player.lua',
    'server/ama_discord.lua',
    'server/ama_crew.lua',
    'server/ama_bitcoin.lua',
    'server/command.lua'
}

client_scripts {
    'client/ama_add.lua',
    'client/spwan.lua',
    'client/event.lua'
}

dependencies {
    'oxmysql'
}