require 'net/http'
require 'uri'  
require 'json'  
def parse_cookie(res)
    return res.response['set-cookie'].split(', ')
end

def get(u,params=nil)
    uri = URI(u)
    case params
    when "",nil
    else
        uri.query = URI.encode_www_form(params)
    end
    begin
        res = Net::HTTP.get_response(uri)
        puts res.body if res.is_a?(Net::HTTPSuccess)
    rescue 
        raise "offline"
    ensure
        #puts res
    end
end

def post(u,data,params)
    uri = URI(u)
    res = Net::HTTP.post_form(uri, 'q' => 'ruby', 'max' => '50')
    puts res.body
end

def post1(u,data=nil)
    req = Net::HTTP::Post.new(u,{'Content-Type' => 'application/json'})  
    req.body = data  
    res = Net::HTTP.new(url.host,url.port).start{|http| http.request(req)}  
    puts res.body            
end

def post2(u,data=nil)
    http = Net::HTTP.new(u, 80)
    path = '/'
    http.use_ssl = false
    resp, data = http.get(path)
    resp, data = http.get(path, headers)
    puts cookies
    puts 'Code = ' + resp.code 
    puts 'Message = ' + resp.message  
    resp.each {|key, val| puts key + ' = ' + val}
end



post2('http://www.baidu.com', { :limit => 10, :page => 3 })
#get('http://www.google.com',{:x=>1})
#
#
