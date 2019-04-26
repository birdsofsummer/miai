require("./fp")

function sleep(n)
   os.execute("sleep " .. n)
end

function productorgen(t)
	return function ()
		local i=0
		while i < #t do
			i=i+1
            local data=t[i]
            coroutine.yield(data)     
            local _t = 2000
                   if(is_table(data)) then
                      _t=data[2]
                   end
            sleep(_t)
		end
	end
end

function consumer(newProductor,cb,n)
    local j=0
    while j<n do
      j=j+1
	  local status, i= coroutine.resume(newProductor)
      cb(j,n,i)
    end
end

function task(t,cb)
	local tt=t()
        local n=#tt
	local newProductor = coroutine.create(productorgen(tt))
	consumer(newProductor,cb,n)
end

