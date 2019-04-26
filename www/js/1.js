const { fromEvent } = rxjs;
const { throttleTime, map, scan } = rxjs.operators;


const init=()=>{
       let [shell,echo,history]=['#shell',"#echo","#history"].map(x=>document.querySelector(x))
       const change_query=()=>{
           console.log(shell.value);
       }
       //fromEvent(shell, 'click').subscribe(change_query);
       //fromEvent(shell, 'change').pipe( scan(x=>x+1,0)) .subscribe(console.log);
       fromEvent(shell, 'change').pipe(
          throttleTime(1000),
         // map(event => event.clientX),
         // scan((count, clientX) => count + clientX, 0)
          map(e=>e.target.value)
        )
       .subscribe(console.log);
}

init()
