fx_version('adamant')
game('gta5')

name 'FBI Job PMenu'
author 'LostSky - Revenge/кali'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'Config.lua',
	'server/main.lua',
	'server/sv_infos.lua'
}

client_script('src/PMenu.lua')

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'client/functions.lua',
	'locales/fr.lua',
	'Config.lua'
}

dependency('es_extended')