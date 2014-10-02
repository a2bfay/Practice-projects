# Bowling calculator for multiple players, 
#   with skill-weighted random result on each roll
# Options at end to repeat games / calc. stats per skill level


# ===============================================
# GAME MECHANICS
#

def newgame
  @players = Array.new
  @frame_scores = Array.new
  @game_scores = Array.new
  
  @player = 1
  @frame_no = 1
  @roll_type = 1
  @pins_remaining = 10
end
  
  
def get_players
  print "How many players(1-4)?  "
    numplayers = gets.chomp.to_i
    numplayers = 1 if numplayers < 1
    numplayers = 4 if numplayers > 4
  get_skill(numplayers)
  reset_arrays
  print_players
end


def get_skill(numplayers)
  puts "Enter skill level 0-15 (2+ = good, 4+ = v.good, 6+ = pro):"
  (1..numplayers).each do |p|
    print "Skill level for player #{p}?  "
    skill = gets.chomp.to_i
    skill = 0 if skill < 0
    @players << skill
  end
end

# prepares nested arrays to be filled during gameplay/scoring
#
def reset_arrays
  @players.length.times do
      @frame_scores << []
      @game_scores << []    
  end
end


def print_players
  puts
  (1..@players.length).each do |p|
    print "P#{p}(#{@players[p - 1]})".rjust(7), "___________ "
  end
  puts
end


def playgame
  until @frame_no == 11
    roll_control(@player)	
  end
  puts unless @stats_mode == true
end


def turn_control(player)
  if player == @players.length
    puts unless @stats_mode == true
    @frame_no += 1
    @player = 1
  else
    @player += 1
  end
  @roll_type = 1 
  @pins_remaining = 10 
end


def roll_control(player)
  if @roll_type == 4					  # for 10th/3rd
    roll_calc(player,1)
    score_progress(player,@frame_no - 1) 
    turn_control(player)    

  elsif @roll_type == 3				  # 1st bonus after 10th fr strike -> to 3rd roll
    roll_calc(player,1)
    @pins_remaining = 10 if @pins_remaining == 0
    @roll_type = 4              

  else
    roll_calc(player,@roll_type - 1)		
    
    if @roll_type == 1          # regular first roll
      if @pins_remaining == 0 and @frame_no == 10
        @roll_type = 3							                 
        @pins_remaining = 10
      elsif @pins_remaining == 0
        score_progress(player,@frame_no - 1)
        turn_control(player)
      else
        @roll_type = 2          
      end
		elsif @roll_type == 2       # regular second roll
		  if @pins_remaining == 0 and @frame_no == 10    
        @roll_type = 4							                 
        @pins_remaining = 10
      else
        score_progress(player,@frame_no - 1)
        turn_control(player)
      end
    end    
  end  
end


def roll_calc(player,type)
  skill = @players[player - 1]
  picks = Array.new
  (skill + 1).times do 
    pins = rand(0..@pins_remaining)
    picks << pins
    break if pins == @pins_remaining
  end
  pins_hit = picks.max  
  
  if type == 0 
    @frame_scores[player - 1] << [pins_hit]
  else 
    @frame_scores[player - 1][@frame_no - 1] << pins_hit
  end

  @pins_remaining = @pins_remaining - pins_hit
end


# ===============================================
# SCORING METHODS
# "i" in next 3 methods is array index of current frame (so @frame_no - 1)
#   should be more descriptive, but lines are already too long --
#   better to create variables for array values being summed, then add? 
#

def score_progress(player,i)
  framesum = @frame_scores[player - 1][i].reduce(:+)
  
  if i >= 2 && @game_scores[player - 1][-2].nil? == true
    update_2prev(player,i)
  end

  if i >= 1 && @game_scores[player - 1][-1].nil? == true
    update_prev(player,i,framesum)
  end
  
  if i == 9 
    @game_scores[player - 1] << @game_scores[player - 1][-1] + framesum
  elsif framesum == 10
    @game_scores[player - 1] << nil
  elsif i == 0
    @game_scores[player - 1] << framesum
  else 
    @game_scores[player - 1] << @game_scores[player - 1][i - 1] + framesum
  end
  
  unless @stats_mode == true
    print @game_scores[player - 1][i].to_s.rjust(6)
    print " ", @frame_scores[player - 1][i].inspect.ljust(12)
  end
end


def update_2prev(player,i)
  if i == 2
    @game_scores[player - 1][-2] = 20 + @frame_scores[player - 1][i][0]
  else
    @game_scores[player - 1][-2] = @game_scores[player - 1][-3] + 20 + @frame_scores[player - 1][i][0]
  end  
end


def update_prev(player,i,framesum)
  if @frame_scores[player - 1][i - 1][0] == 10 && @frame_scores[player - 1][i][0] == 10
      if i == 9
        @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + @frame_scores[player - 1][i][0] + @frame_scores[player - 1][i][1]
      end
    return                               
    
  elsif i == 1 
    if @frame_scores[player - 1][0][0] == 10
      @game_scores[player - 1][0] = 10 + framesum
    else
      @game_scores[player - 1][0] = 10 + @frame_scores[player - 1][1][0]
    end
    
  else
    if @frame_scores[player - 1][i - 1][0] == 10
        if i == 9 
          @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + @frame_scores[player - 1][i][0] + @frame_scores[player - 1][i][1]      
        else
          @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + framesum
        end
    else
      @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + @frame_scores[player - 1][i][0]
    end
  end
end


# ===============================================
# STATS TESTS
#

# average score by skill setting
#
def average_test(limit)
  (0..15).each do |skill|
    gamecount = 0
    pintotal = 0
    minscore = 300
    maxscore = 0

    until gamecount == limit
      newgame
      @players << skill
      reset_arrays
      playgame
      gamecount += 1
      pintotal += @game_scores[0][-1]
            
      minscore = @game_scores[0][-1] if @game_scores[0][-1] < minscore
      maxscore = @game_scores[0][-1] if @game_scores[0][-1] > maxscore
    end

    print "#{skill}\t#{gamecount}\tavg"
    print "#{(pintotal / gamecount)}".rjust(4), "#{minscore}/#{maxscore}".rjust(9), "\n"
    puts
  end
end


# frequency of perfect game by skill setting
#
def perfect_test(limit)
  (0..15).each do |skill|
    gamecount = 0
    perfect_games = 0 
    until gamecount == limit
      newgame
      @players << skill
      reset_arrays
      playgame
      gamecount +=1      
      perfect_games += 1 if @game_scores[0][-1] == 300  
    end
    print skill, "\t", gamecount, "\t", perfect_games, "\n"
  end
end


# head-to-head wins for consecutive skill levels
# (n.b. diff greatest at low skill - approach 50/50 at high)
#
def upset_test(limit = 1)
  puts
  (0..14).each do |skill|
    wins = [0,0,0]
    gamecount = 0
    until gamecount == limit
      newgame
      @players << skill
      @players << (skill + 1)
      reset_arrays
      playgame
      wins[0] += 1 if @game_scores[0][-1] > @game_scores[1][-1]
      wins[1] += 1 if @game_scores[0][-1] < @game_scores[1][-1]
      wins[2] += 1 if @game_scores[0][-1] == @game_scores[1][-1]
      gamecount += 1
    end
    print @players.inspect.rjust(8), "   ", wins.inspect, "\n"
  end
end


# ===============================================
# PLAY MODES:
#

def stats_tests(limit)
  @stats_mode = true    # use to disable gameplay screen output
  puts
  average_test(limit)
  perfect_test(limit)
  upset_test(limit)  
end


def repeat_check
  puts "\nRepeat game with these players (y/n/stats/quit)?"
  repeat = gets.chomp.downcase
  if repeat == "stats"
    print "Number of games per test?  "
    limit = gets.chomp.to_i
    stats_tests(limit)
  elsif repeat == "n"
    single_game
  elsif repeat == "y"
    curr_players = @players
    newgame
    @players = curr_players
    reset_arrays
    print_players
    playgame
    repeat_check
  else
    return
  end  
end


def single_game
  newgame
  get_players
  playgame
  repeat_check
end


single_game