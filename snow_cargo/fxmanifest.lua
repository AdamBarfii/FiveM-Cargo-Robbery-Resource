shared_script '@hz_jesus/modules/native/shared.lua'
fx_version 'cerulean'
game 'gta5'

name "hz_cargo"
description "Cargo Robbery"
author "SnowMan"
version "1.0.1"

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}
lua54 'yes'