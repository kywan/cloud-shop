fx_version "cerulean"
game "gta5"

lua54 "yes"
use_experimental_fxv2_oal "yes"

author "yiruzu"
description "Cloud Resources - Shop"
version "1.3.0"

support "https://discord.gg/jAnEnyGBef"
repository "https://github.com/yiruzu/cloud-shop"
license "CC BY-NC"

shared_scripts {
    "@ox_lib/init.lua",
    "shared/utils/*.lua",
}
server_scripts {
    "bridge/server/*.lua",
    "server/utils/*.lua",
    "server/modules/*.lua",
    "server/*.lua",
}
client_scripts {
    "client/utils/*.lua",
    "client/modules/*.lua",
    "client/*.lua",
}

files {
    "web/dist/**/*",
    "config/*.lua",
}

ui_page { "web/dist/index.html" }

dependencies { "ox_lib" }
