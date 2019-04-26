function pp(t) 
    return function()
        for i=1,#t do
             coroutine.yield(t[i])
        end
    end
end

function consumer(newProductor,n)
    for i=1,n do
         local status, value = coroutine.resume(newProductor)
          print(value)
    end
end
function task(t)
    n=#t
    newProductor = coroutine.create(pp(t))
    consumer(newProductor,2)
end
t={10,20,30}
task(t)
