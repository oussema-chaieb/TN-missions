fx_version 'cerulean'
game 'gta5'

author 'DON'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

lua54 'yes'