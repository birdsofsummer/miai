require 'json'
require 'pp'
a=`ls /`
b=a.split(%r{\n})
#c=JSON.parse(b)
#pp c
pp b
uhttpd.send("Status: 200 OK\r\n")
