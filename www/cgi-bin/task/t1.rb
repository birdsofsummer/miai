require 'thread'

def t1
    count = 0
    arr = []
     
    10.times do |i|
       arr[i] = Thread.new {
          sleep(rand(0)/10.0)
          Thread.current["mycount"] = count
          count += 1
       }
    end
     
    arr.each {|t| t.join; print t["mycount"], ", " }
    puts "count = #{count}"
end

def t2

    count1 = count2 = 0
    difference = 0
    counter = Thread.new do
       loop do
          count1 += 1
          count2 += 1
       end
    end
    spy = Thread.new do
       loop do
          difference += (count1 - count2).abs
       end
    end
    sleep 1
    puts "count1 :  #{count1}"
    puts "count2 :  #{count2}"
    puts "difference : #{difference}"
end

def tm
    mutex = Mutex.new
     
    count1 = count2 = 0
    difference = 0
    counter = Thread.new do
       loop do
          mutex.synchronize do
             count1 += 1
             count2 += 1
          end
        end
    end
    spy = Thread.new do
       loop do
           mutex.synchronize do
              difference += (count1 - count2).abs
           end
       end
    end
    sleep 1
    mutex.lock
    puts "count1 :  #{count1}"
    puts "count2 :  #{count2}"
    puts "difference : #{difference}"
end


def tdead
    mutex = Mutex.new
     
    cv = ConditionVariable.new
    a = Thread.new {
       mutex.synchronize {
          puts "A1"
          cv.wait(mutex)
          puts "A2"
       }
    }
    puts "--------m-----------------"
    b = Thread.new {
       mutex.synchronize {
          puts "B1"
          cv.signal
          puts "B2"
       }
    }
    a.join
    b.join
end
