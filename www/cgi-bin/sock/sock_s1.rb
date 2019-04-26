require 'socket'
host = 'localhost'    
port = 80            
path = "/index.htm" 
socket = TCPSocket.open(host,port)
#request = "GET #{path} HTTP/1.0\r\n\r\n"
#socket.print(request)            
response = socket.read          
headers,body = response.split("\r\n\r\n", 2) 
print body       
