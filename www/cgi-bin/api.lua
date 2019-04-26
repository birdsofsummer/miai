function format(t)
   if type(t) == "table"
   then
     return table.concat(t,", ")
   else
     return t
   end
end 

function env2txt(env)
	local ee=""
	for k,v in pairs(env) do
	        ee=ee..k..":"..format(v).."\n"
	end
	return ee
end

function log(env)
	file = io.open("/tmp/web.txt", "a+")
	io.output(file)
	io.write(env)
	io.close(file)
end


function shell(cmd)
      local t = io.popen(cmd)
      local a=""
      for x in t:lines() do
           a=a.."\n"..x
      end
      t:close()
      return a
end

function ls()
	local l='echo ls /|sh'
	return shell(l)
end

function handle_request(env)
        local d=env2txt(env)
        log(d)
        local dir=ls()
        uhttpd.send("Status: 200 OK\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
       --uhttpd.send("Content-Type:text/html \r\n\r\n")
        uhttpd.send(dir)
end
