require 'socket'             
require 'rack'
require 'rack/lobster'
require 'uri'
#https://practicingruby.com/articles/implementing-an-http-file-server
#https://oldwiki.archive.openwrt.org/doc/uci/uhttpd
#https://rxjs.dev/guide/overview

def now
    Time.now.ctime
end

def log(x)
  STDERR.puts  "[#{now}] #{x}"
end

app = Rack::Lobster.new

app1 = Proc.new do
  response = "#{now}\n"
  [ '200', 
   [ {'Content-Type' => 'text/html'}, 
       {"Access-Control-Allow-Origin"=>"*\r\n"},
       {"Access-Control-Allow-Methods"=>" POST, GET, OPTIONS, DELETE"},
       {"Access-Control-Allow-Headers"=>" Content-Type, Accept, X-Requested-With, remember-me,token"},
       {"Access-Control-Allow-Credentials"=>" true"},
       {"Access-Control-Max-Age"=>"3600"},
       #"Date: Tue, 14 Dec 2010 10:48:45 GMT"
       {"Date: Tue" => " #{now} UTC+8"},
       {"Server"=>"Ruby"},
       {"Content-Type"=>"text/html; charset=iso-8859-1"},
       {"Content-Length"=>" #{response.length}\r\n\r\n}"} ],
   [response,1,2,3,4] ]
end


#res=parse_req(request)
def parse_req1(request)
    method, full_path = request.split(' ')
    path, query = full_path.split('?')
    {
        'REQUEST_METHOD' => method,
        'PATH_INFO' => path,
        'QUERY_STRING' => query
    }    
end

parse_req=Proc.new do |request|
    parse_req1(request)
end




WEB_ROOT = '..'
CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}
DEFAULT_CONTENT_TYPE = 'application/octet-stream'
def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end
def requested_file(request_line)
  # ... implementation details to be discussed later ...
end

server = TCPServer.open(2000) 
loop {                       
  Thread.start(server.accept) do |session|
    request = session.gets
    log request
    3.times do 
        log session.gets
        log "\n"
    end
    res=parse_req.call(request)
    status, headers, body = app.call(res)
    session.print "HTTP/1.1 #{status}\r\n"
    headers.each do |h|
          h.each do |key, value|
              session.print "#{key}: #{value}\r\n"
          end
    end
    session.print "\r\n"
    body.each do |b|
        session.print b
    end
 #   session.puts(body)
    session.close
  end
}

