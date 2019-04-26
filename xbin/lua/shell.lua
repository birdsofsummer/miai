function shell(cmd)
    local a=io.popen(cmd)
    b=a:read("*a")
    a:close()
    return b
end

function shell1(cmd)
    local a=io.popen(cmd)
    b={}
    for i in a:lines() do
        table.insert(b,i)
    end
    a:close()
    return b
end
