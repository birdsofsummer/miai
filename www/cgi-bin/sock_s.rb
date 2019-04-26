require 'socket'             
server = TCPServer.open(2000) 
loop {                       
  Thread.start(server.accept) do |client|
    client.puts(Time.now.ctime) 
    client.puts "Closing the connection. Bye!"
    client.close               
  end
}

