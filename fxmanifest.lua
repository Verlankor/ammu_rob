fx_version 'cerulean'
game 'gta5'

description 'QB-Ammu-Rob'
version '1.0'

shared_script 'config.lua'

client_scripts {
  'client.lua',
}

lua54 'yes'

server_script 'server.lua'

dependencies {
  'qb-core',
  'qb-target'
}

escrow_ignore {
  '*.lua',
}