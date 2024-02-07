--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'Vending Machines'
author       'Kmack710'
version      '4.20'

shared_scripts {
    '@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	'data/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'data/server.lua',
}
