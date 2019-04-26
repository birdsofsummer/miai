#!/usr/bin/env lua


local uloop = require("uloop")
uloop.init()
-- timer example 1
function t1()
	local timer
	function t()
		print("1000 ms timer run");
		timer:set(1000)
	end
	timer = uloop.timer(t)
	timer:set(1000)
end
-- timer example 2
uloop.timer(function() print("2000 ms timer run"); end, 2000)

-- timer example 3
uloop.timer(function() print("3000 ms timer run"); end, 3000):cancel()

-- process
function p1(r)
    print("Process 1 completed")
    print(r)
end

function p2(r)
	print("Process 2 completed")
	print(r)
	uloop.cancel()
end

uloop.timer(
function()
	uloop.process("/xbin/bird1", {"a","b"}, {"PROCESS=1"}, p1)
end, 1000
)

uloop.timer(
function()
	uloop.process("uloop_pid_test.sh", {"foo", "bar"}, {"PROCESS=1"}, p1)
end, 1000
)
uloop.timer(
function()
	uloop.process("uloop_pid_test.sh", {"foo", "bar"}, {"PROCESS=2"}, p2)
end, 2000
)
--[[
local socket = require "socket"
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 8080)

udp_ev = uloop.fd_add(udp, function(ufd, events)
local words, msg_or_ip, port_or_nil = ufd:receivefrom()
print('Recv UDP packet from '..msg_or_ip..':'..port_or_nil..' : '..words)
if words == "Stop!" then
udp_ev:cancel()
end
end, uloop.ULOOP_READ)

udp_count = 0
udp_send_timer = uloop.timer(
function()
local s = socket.udp()
local words
if udp_count > 3 then
words = "Stop!"
udp_send_timer:cancel()
else
words = 'Hello!'
udp_send_timer:set(1000)
end
print('Send UDP packet to 127.0.0.1:8080 :'..words)
s:sendto(words, '127.0.0.1', 8080)
s:close()

udp_count = udp_count + 1
end, 3000
)
]]
uloop.run()
--[[

ULOOP_EDGE_TRIGGER
cancel
init
run
ULOOP_WRITE
ULOOP_BLOCKING
process
timer
ULOOP_READ
fd_add
_VERSION


]]
