uci set uhttpd.main.lua_prefix=/api
uci set uhttpd.main.lua_handler=/www/cgi-bin/api.lua
/etc/init.d/uhttpd restart


