require 'net/http'                 
host = 'localhost'         
path = "/index.htm"
http = Net::HTTP.new(host)        
headers, body = http.get(path)    
if headers.code == "200"          
  print body                        
else                                
  puts "#{headers.code} #{headers.message}" 
end

