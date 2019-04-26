require("./shell")
require("./fp")
require("./co")
require("ubus")
--require("uloop")

function inspect_task(fn)
    return function(j,n,i)
        if (is_table(i)) then
            print(string.format("[%s/%s]:%s|%s", j,n,i[1],i[2]))
        else
            print(string.format("[%s/%s]:%s", j,n,i))
        end
        fn(i)
    end
end



function reset_player(v)
    local v=v or 100
	local conn = ubus.connect()
	local s1 = conn:call("mediaplayer", "player_set_volume", {volume=v })
	local s2 = conn:call("mediaplayer", "player_set_loop", {type=0,media="common"})
	conn:close()
end

function play(j,n,i) 
        local url
        if (is_table(i)) then
		print(string.format("[%s/%s]:%s|%s", j,n,i[1],i[2]))
		url=i[1]
        else
              url=i 
	      print(string.format("[%s/%s]:%s|%s", j,n,i,10))
        end
	local conn = ubus.connect()
	local s3 = conn:call("mediaplayer", "player_play_url", { url=url,type=0 })
	conn:close()
end

function url_gen(k,v)
      SOUND_DIR="file:///data/txt/sound/"
      return SOUND_DIR..v
end
function song_list_without_duration()
	 local  a= shell1('ls /data/txt/sound')
	 local  b=map(url_gen,a)
	 local  c=shell1("cat /data/txt/morning.txt")
	 local  d=extend(b,c)
	 return d
end

function song_list_with_duration()
	 local  a= shell1('ls /data/txt/sound')
	 local  b=map(url_gen,a)
	 local  c=txt2table('/data/txt/u.txt')
	 return c
end

function speak(s)
    --ubus -t 1000 call mibrain text_to_speech "{\"text\":\"$tts\",\"save\":0}"
 	local conn = ubus.connect()
	local s2 = conn:call("mibrain", "text_to_speech", {text=s,save=0})
	conn:close()
end

function read_a_book(s)
    local t=function () return split_text(s) end
    local speak2=inspect_task(speak)
    task(t,speak2)
end
function test_read()
   local s=shell("curl http://down1.bookbao99.net:8026/fulltext/375/375880.txt")
   read_a_book(s)
end

test_read()


--task(song_list_with_duration,play)
--task(song_list_without_duration,play)
