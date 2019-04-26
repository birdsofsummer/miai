#!/usr/bin/env lua
uloop = require("uloop")
function utask(fn,interval,n)
    interval=interval or 2000
    uloop.init()
    local i=0
    function t1()
        local timer
        function t()
            fn(i,n)
            i=i+1
            if i>n then 
                uloop.cancel()
            end
            timer:set(interval)
        end
        timer = uloop.timer(t)
        timer:set(interval)
    end
    t1()
    uloop.run()
end

utask(print,1000,10)
