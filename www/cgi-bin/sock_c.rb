require 'socket'    
hostname = '192.168.0.104'
port = 2000
s = TCPSocket.open(hostname, port)
while line = s.gets  
  puts line.chop    
end
s.close            
