require 'rest-client'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'  
require 'csv'
require 'json'  
require 'ruby-cheerio'

#https://github.com/rest-client/rest-client#exceptions-see-wwww3orgprotocolsrfc2616rfc2616-sec10html
#

def headers_gen(headers=nil)
    h={
 #            'Cookie' => @cookies[0].split('; ')[0],
              'Referer' => "",
              "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.5 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.4",              
              'Content-Type' => 'application/x-www-form-urlencoded',
        }
     return h.merge(headers)
end


def test
    headers={content_type: :json, accept: :json}
    headers1={accept: :json}
    u='http://www.baidu.com'
    ssl_ca_file='myca.pem'
    payload={'x' => 1}.to_json
    payload1={param1: 'one', nested: {param2: 'two'}}
    payload2={params: {id: 50, 'foo' => 'bar'}}
    payload3=  {
    :transfer => {
      :path => '/foo/bar',
      :owner => 'that_guy',
      :group => 'those_guys'
    },
     :upload => {
      :file => File.new(path, 'rb')
    }
  }
    r=RestClient.get u
    r=RestClient.get(u, headers={})
    r=RestClient.get u, headers1
    r=RestClient.get u, payload2

    r=RestClient.post(u, payload, headers={})
    r=RestClient.post u, payload1
    r=RestClient.post(u,payload3)
    r=RestClient.post u, payload, headers
    RestClient.post '/data', :myfile => File.new("/path/to/image.jpg", 'rb')
    RestClient.post '/data', {:foo => 'bar', :multipart => true}


    r=RestClient.delete u
    r=RestClient::Request.execute(method: :get, url: u, timeout: 10)
    r=RestClient::Request.execute(method: :get, url: u,
                            ssl_ca_file: ssl_ca_file,
                            ssl_ciphers: 'AESGCM:!aNULL')
    r=RestClient::Request.execute(method: :delete, 
                                  url: u,
                            payload: payload, 
                            headers: headers)
    RestClient::Request.execute(method: :get, 
                                url: u,
                            timeout: 10, 
                            headers: {params: {foo: 'bar'}} # ?foo=bar
                            )

=begin
    r.code
    r.cookies
    r.headers
    r.body
    r.history
    r.request.url
    r.history.map {|x| x.request.url}
=end


resource = RestClient::Resource.new u
resource.get


private_resource = RestClient::Resource.new u, 'user', 'pass'
private_resource.put File.read('pic.jpg'), :content_type => 'image/jpg'


site = RestClient::Resource.new(u)
site['posts/1/comments'].post 'Good article.', :content_type => 'text/plain'


begin
    RestClient.get u
rescue RestClient::ExceptionWithResponse => e
    e.response
end



RestClient.get 'http://localhost:12345'

end 



def test1
    u1="http://example.com/login"
    u2="https://example.com/session"
    HEADERS_HASH = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.5 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.4"}
    page = Nokogiri::HTML(open(u1, HEADERS_HASH))
    token = page.css("form.login_box div input")[0]['value']
    d={"authenticity_token" => token, "login" => 'username', "password" => 'password', "remember_me" => 1, 'commit' => 'Sign In'}
    login_resp = RestClient.post(u2,d )
end

def parse_html(s)
    jQuery = RubyCheerio.new(s)
    jQuery.find('a').each do |x|
    ruby_gems = Array.new
       p x.prop('a','href')
       p x.text
       ruby_gems << { name: gem_name_version[0].strip, version: gem_name_version[1].strip, downloads: gem_downloads }
    end
    p ruby_gems 
end
