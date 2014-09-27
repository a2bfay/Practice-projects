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


# routine below used to compare (0..pins+skill) method and new multi-pick system
# requires 2-player game with diff methods in code for roll_results (now removed)

# _________________________________________________________
# HEAD TO HEAD WEIGHTING TEST
# while testing weight system : player 1 always new, rest old
# use two-player setup to tally wins

# puts "skill to test?"
# skill = gets.chomp.to_i

# SO FAR -- looks like old system generates higher results, usually beats new
# new gives much better gradation of skill levels (old, skill 1 avg's ~180)
# skill 0 averages around 90

(0..15).each do |skill|

  gamecount = 0
  wins = [0,0,0]
  pintotal = [0,0]
  minscores = [300,300]
  maxscores = [0,0]
  diff = 0

  until gamecount == 1000 # or diff == 5000

    newgame
    
    2.times do
      @players << skill
      @frame_scores << []
      @game_scores << []    
    end

    playgame
    gamecount += 1
    diff = (wins[0] - wins[1]).abs
    
    pintotal[0] += @game_scores[0][-1]
    pintotal[1] += @game_scores[1][-1]
    
    minscores[0] = @game_scores[0][-1] if @game_scores[0][-1] < minscores[0]
    maxscores[0] = @game_scores[0][-1] if @game_scores[0][-1] > maxscores[0]
        
    minscores[1] = @game_scores[1][-1] if @game_scores[1][-1] < minscores[1]
    maxscores[1] = @game_scores[1][-1] if @game_scores[1][-1] > maxscores[1]
   
    wins[2] += 1 if @game_scores[0][-1] == @game_scores[1][-1]
    wins[0] += 1 if @game_scores[0][-1] > @game_scores[1][-1]  
    wins[1] += 1 if @game_scores[0][-1] < @game_scores[1][-1]
        
  end

  print "#{skill}\t#{gamecount}\t#{wins.inspect}\n"
  print "\t\t", (pintotal[0] / gamecount), " ", minscores[0], " ", maxscores[0], "\n"
  print "\t\t", (pintotal[1] / gamecount), " ", minscores[1], " ", maxscores[1]
  puts
  puts
  
end