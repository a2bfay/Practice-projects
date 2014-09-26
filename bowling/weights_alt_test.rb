# weighting system based on best of n picks
# set to show result frequencies at skill levels 0-10
#

(0..10).each do |skill|

  puts "\n* #{skill} *"

  totals = Array.new 
  (0..10).each do
    totals << []
  end

  10.times do
  
    picks = Array.new
    
    (skill + 1).times do 
      pins = rand(0..10)
      picks << pins
      if pins == 10     # save cycles if already get max...
        print "!"
        break
      end
    end
    
    puts picks.inspect
    best = picks.max
    #puts ">>  #{best}  <<\n"
    
    totals[best] << best
    
  end

  # puts totals.inspect
  puts
  
  freq = Array.new
  
  (0..10).each do |i| 
    freq << totals[i].length
    print totals[i].length, "  "
  end
  puts
  puts (freq.max - freq.min)

  
end

