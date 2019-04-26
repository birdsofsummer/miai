UBUS="/ubus"
save_json = (k="",v=null)=>{
    let store=window.localStorage;
    let v1=JSON.stringify(v||{});
    if (v) {
       store[k]=v1
    }else{
        let d1 = store[k]
        let d=d1 ? JSON.parse(d1) : {}
        return d
    }
}

each_v=fn=>(o={})=>Object.entries(o).map(fn)
http=(u)=>(d)=>fetch(u,{method:"POST",body:JSON.stringify(d)}).then(x=>x.json())
post=http(UBUS)

data_format=(id,method="call")=>cmd=>{
    return {
      "jsonrpc": "2.0",
      "id": 1,
       method,
      "params": [id,...cmd],
    }
}

save_user=(user)=>{
   t=Date.now()+user.result[1].expires*1000;
   user.tt=t
   save_json("user",user)
}

check_id=async()=>{
    let user=save_json('user');
    let id0=user.result[1].ubus_rpc_session
    let ok=user.tt > Date.now()
    let id=ok ? id0 : await login()
    return id
}
login=async (username="root",password="root",id=1)=>{
    let
    id0="0".repeat(32),
    d={
      "jsonrpc": "2.0",
       id,
      "method": "call",
      "params": [ id0, "session", "login", { username, password,} ],
    }
    user= await post(d);
    let {jsonrpc,result:[,{ubus_rpc_session,}]}=user
    save_user(user)
    return ubus_rpc_session
}
run=async(cmd)=>{
    id=await login();
    d=data_format(id)(cmd)
    return post(d)
}
send=async(cmd)=>{
    id=await login();
    d=data_format(id,"send")(cmd)
    return post(d)
}

run1=async(cmd)=>{
    let id=await check_id()
    let d=data_format(id)(cmd)
    return post(d)
}

play=async(s="小爱同学,现在几点啦")=>{
    cmd=["mibrain","text_to_speech",{"text":s},];
    run(cmd)
}

system=()=>{
    t=["system","info",{},]
    run(t)
}

mediaplayer=()=>{
    methods={
        "player_get_play_status":{},
        "player_play_private_fm":{},
        "player_get_latest_playlist":{},
        "player_get_context":{},
        "test":{},
        "get_shutdown_timer":{},
        "get_media_volume":{},
        "player_reset":{},
        "player_retore_last_volume":{},
    }
    add_head=a=>(arr=[])=>[a,...arr]
    return each_v(add_head("mediaplayer"))(methods)
    //Promise.all(cmds.map(run1))
}
mediaplayer()
//play();

file=(path="/tmp/mipns/mibrain/mibrain_directive.log")=>run(["file", "read", {path}])
write=(path="/tmp/t",data="123")=>run(["file", "write", {path,data}])
dir=(path="/tmp/mipns/mibrain/" )=>run(["file", "list", {path} ])
cmd=(command="ls",params=["/"] )=>run(["file", "exec", {command,params,"env":{}} ])
service=()=>run(["service", "list", {} ])


/*


'service' @a00c25bd
	"set":{"name":"String","script":"String","instances":"Table","triggers":"Array","validate":"Array"}
	"add":{"name":"String","script":"String","instances":"Table","triggers":"Array","validate":"Array"}
	"list":{"name":"String","verbose":"Boolean"}
	"delete":{"name":"String","instance":"String"}
	"update_start":{"name":"String"}
	"update_complete":{"name":"String"}
	"event":{"type":"String","data":"Table"}
	"validate":{"package":"String","type":"String","service":"String"}
	"get_data":{"name":"String","instance":"String","type":"String"}


    "read":{"path":"String"}
	"write":{"path":"String","data":"String"}
	"list":{"path":"String"}
	"stat":{"path":"String"}
	"md5":{"path":"String"}
	"exec":{"command":"String","params":"Array","env":"Table"}
 */

