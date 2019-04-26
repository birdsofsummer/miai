function each(fn,t)
   for k,v in pairs(t) do
       fn(k,v)
   end
end

function show(t)
    each(print,t)
    return t
end

function show_key(t)
    p=function(k,v) print(k) end
    each(p,t)
    return t
end

function map(fn,t)
   t1={}
   for k,v in pairs(t) do
       t1[k]=fn(k,v)
   end
   return t1
end

function reduce(fn,t,acc)
   r=acc
   for k,v in pairs(t) do
        r=fn(r,k,v)
   end
   return r
end

function filter(fn,t)
   t1={}
   for k,v in pairs(t) do
      if (fn(k,v)) then
         table.insert(t1,t[k])
      end
   end
   return t1
end


function table2str(t,sep1,sep2,cb)
    sep1=sep1 or "&" 
    sep2=sep2 or "=" 
    function join_str(acc,k,v)
          local s=sep1
          if (acc == "") then
              s=""
          end
         return acc..s..k..sep2..v
    end
    cb=cb or join_str
  return reduce(cb,t,"")
end

function split_text(s,size)
    s=tostring(s)
    size=size or 10000
    local t={}
    local l=string.len(s)
    if  l==0 then return t end
    for i=1,1+l/size do
        local p1=(i-1)*size+1
        local p2=p1+size-1
        if i==1 then 
            --p2=size
        end
        t[i]=string.sub(s,p1,p2)
    end
    return t
end


function txt2table(file)
  local sep=","
  local cmd ='cat '..file
  local  a=shell1(cmd)
  f1=function(k,v)
      local l=string.len(v)
      local s=string.find(v,sep)
      v1,v2 =string.sub(v,0,s-1) ,string.sub(v,s+1,l)
      return {v1,v2}
  end
 return map(f1,a)
end

function extend(...)
local s = {}
  for i, v in ipairs{...} do   
    for i1,v1 in ipairs(v) do
        table.insert(s,v1)
    end
  end
  return s
end

function is_table(t)
     return type(t)=="table"
end

function test_fp()
    function add(acc,k,v) 
        return acc+k
    end
    reduce(add,{1,2,3},0)
    map(function(k,v) return v+1 end,{1,2,3})
    show(filter(function(k,v)  return v>2 end,{1,2,3}))
    t={x=1,y=2,z=3}
    show(t)
    show_key(t)
    table2str(t)
    table2str(t,",",':')
end


