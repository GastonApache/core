fx_version 'cerulean'
game 'gta5'

author 'AMA Framework'
description 'Framework FiveM moderne et optimisé'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/config.lua',
    'shared/discord_config.lua',
    'shared/functions.lua',
    'shared/serialization.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/player.lua',
    'server/discord_logger.lua',
    'server/crews.lua',
    'server/bitcoin.lua',
    'server/commands.lua'
}

client_scripts {
    'client/main.lua',
    'client/spawn.lua',
    'client/events.lua'
}

dependencies {
    'oxmysql'
}