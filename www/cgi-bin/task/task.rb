def add(x)
    puts x
end

def test_q
    queue = Queue.new
    t1=Thread.new 10 do
        10.times do |i|
             sleep rand(i) # 让线程睡眠一段时间
             queue << i
             puts "ppppp #{i}" 
        end
    end
    t2=Thread.new 100 do
        10.times do |x|
           v=queue.pop
           puts "ccccc#{v}"
           sleep 0.01
        end
    end
    t1.join
    t2.join
end

def test_q1
    @num=200
    @mutex=Mutex.new
    @full=false 

    def buyTicket(num)
         @mutex.lock
              c=yield 
              puts c.to_s
              if @num>=num
                   @num=@num-num
                   puts "#{num}"
              else

                   puts "0"
                   @full=true
              end
         @mutex.unlock
    end
     
    ticket1=Thread.new 10 do
         10.times do |value|
             case @full
             when false
                 buyTicket(15){|a,b|[1,value]}
                 sleep 0.01
             else 
                 Thread.exit
             end
         end
    end
     
    ticket2=Thread.new 10 do
         10.times do |value|
         case @full
         when false
             buyTicket(20){|a,b|[2,value]}
             sleep 0.01
         else 
             Thread.exit
         end

         end
    end
    sleep 1
    ticket1.join
    ticket2.join
end
#Thread.new{_test1}
test_q1
