# Bowling simulator for multiple players with skill-weighted random result on each roll
# [eventual] Option to score game in progress or after all rolls complete - for now latter disabled
# Options at end to repeat games for stats-checking

# 9/23 score-in-progress finished -- multiplayer working, skill working
#   
# existing methods: roll, roll_results(called by roll)
#                   score_progress, update_2prev, update_prev (both called by score_progress)
#                   score_complete, tally_comp(called by score_complete)
# added:            newgame, getplayers, turn_control

# CHANGES NEEDED:   array to store player/skill combinations -- check (simple; no nesting required)
#                   player number as argument for methods -- check
#                   way to increment frames/rolls across players -- check
#                   extra nesting/layer to @frame_scores and @game_scores arrays --> with changes to all refs 
#                   in general : @frame_scores[i][0] --> @frame_scores[player][frame][roll] -- check
# PLUS:             now adding skill variation -- check
#                   DECIDED ON : arithmetic rather than exponential approach -- gets to pro level w/ much simpler math


# ===========================================

def newgame

  puts "\n========================================================="
  
  @players = Array.new
  @frame_scores = Array.new
  @game_scores = Array.new
    
  @player = 1
  @frame_no = 1
  @roll_type = 1
  @pins_remaining = 10
  
end
  
  
def getplayers
    
  print "How many players(1-4)?  "
  numplayers = gets.chomp.to_i
    numplayers = 1 if numplayers < 1
    numplayers = 4 if numplayers > 4
  puts "Enter skill level between 0 and 100 (10+ = good, 20+ = v.good, 30+ = pro):"
  (1..numplayers).each do |p|
    print "Skill level for player #{p}?  "
    skill = gets.chomp.to_i
      skill = 0 if skill < 0
      skill = 100 if skill > 100
    @players << skill
    @frame_scores << []
    @game_scores << []    
  end
  print @players.inspect, @frame_scores.inspect, @game_scores.inspect
end


def turn_control(player)
  
  puts "\nturn control: player #{player} #players #{@players.length}"
  
  if player == @players.length
    @frame_no += 1
    @player = 1
  else
    @player += 1
  end

  @roll_type = 1 
  @pins_remaining = 10 
end


def roll(player)
	
  if @roll_type == 4					  # only for 10th/3rd
    puts "\n> > > #{@pins_remaining}"
    roll_results(player,2)
    score_progress(player,@frame_no - 1) 
    turn_control(player)
    
  elsif @roll_type == 3				  # only for 1st bonus after 10th frame strike, so array index always =1
    roll_results(player,1)			# --> means always have 3rd roll; don't score
    puts "\n    > #{@pins_remaining}"
      if @pins_remaining == 0
        @pins_remaining = 10
        puts "\n  > > #{@pins_remaining}"
      end		
      @roll_type = 4            # don't increment frame here because always passes to another roll

  else
    roll_results(player,@roll_type - 1)		
	
    if @roll_type == 1
      if @pins_remaining == 0 and @frame_no == 10    # 10th fr strike
        @roll_type = 3							                 # --> to 1st bonus after strike
        @pins_remaining = 10
      elsif @pins_remaining == 0
        score_progress(player,@frame_no - 1)
        turn_control(player)
      else
        @roll_type = 2
      end
		elsif @roll_type == 2  
		  if @pins_remaining == 0 and @frame_no == 10    # using pins_rem covers spare and strike here
        @roll_type = 4							                 # spare sends to final (3rd) bonus roll
        @pins_remaining = 10
      else
        score_progress(player,@frame_no - 1)
        turn_control(player)
      end
    end
  end
end


def roll_results(player,type)						
  
  skill = @players[player - 1]
  
  print "\nplayer#{player} skill#{skill}"
  
  # skill_limit = ((@pins_remaining + 1) ** skill) - 1      # DISCARDED -- math operations b/c too taxing as 300 games become more likely
  # skill_pick = rand(0..skill_limit)
  # pins_hit = (skill_pick ** (1.0/skill)).to_i
  
  alt_limit = (@pins_remaining) + skill
  alt_pick = rand(0..alt_limit)
  if alt_pick > @pins_remaining
    alt_pick = @pins_remaining
  end
  pins_hit = alt_pick
  print "\t#{alt_limit}/#{pins_hit}"
  # diff = pins_hit - alt_pick
  # @testsum += diff
  # # if pins_hit >= @pins_remaining
    # pins_hit = @pins_remaining
  # end
  @pins_remaining = @pins_remaining - pins_hit
    
  if type == 0 
    @frame_scores[player - 1] << [pins_hit]   		# math for bonus cases handled in roll method
  else 
    @frame_scores[player - 1][@frame_no - 1] << pins_hit
  end
  # print "\t", @frame_scores[player - 1].inspect # for testing
  
end


# works frame by frame; means never looks forward, also never has to look back >3 frames
#
def score_progress(player,i)
  puts "\np#{player}sc#{i}"
  print "\n", @frame_scores[player - 1][i].inspect
  print "\n\t\t\t", @game_scores[player - 1].inspect, "\n"
   
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
    puts "line #{__LINE__} - nil for 10 frame"  # this now adding extra nils w/ function separated out...
  elsif i == 0
    @game_scores[player - 1] << framesum
    puts "line #{__LINE__} - first frame != 10"
  else 
    @game_scores[player - 1] << @game_scores[player - 1][i - 1] + framesum
    puts "line #{__LINE__} regular addition for frame>=2"
  end

  print "-->\t", @frame_scores[player - 1][i].inspect
  print "\n\t\t", @game_scores[player - 1][i].inspect, "\t", @game_scores[player - 1].inspect, "\n\n"
end


# nil two frames back *always* means consecutive strikes preceding
#
def update_2prev(player,i)

  if i == 2
    @game_scores[player - 1][-2] = 20 + @frame_scores[player - 1][i][0]
    puts "line #{__LINE__} - 2prev:\t#{@game_scores[player - 1].inspect}"
  else
    @game_scores[player - 1][-2] = @game_scores[player - 1][-3] + 20 + @frame_scores[player - 1][i][0]
    puts "line #{__LINE__} - 2prev:\t#{@game_scores[player - 1].inspect}"
  end
  
end


# only alters value of prior frame when appropriate -- never appends current
#
def update_prev(player,i,framesum)

  if @frame_scores[player - 1][i - 1][0] == 10 && @frame_scores[player - 1][i][0] == 10
    puts "line #{__LINE__} - two consec strikes"
      if i == 9
        @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + @frame_scores[player - 1][i][0] + @frame_scores[player - 1][i][1]
        puts "line #{__LINE__} - strike in 9th/10th frames"
        puts "\t\t\t#{@game_scores[player - 1].inspect}"
      end
    return                               
    
  elsif i == 1 
    if @frame_scores[player - 1][0][0] == 10
      @game_scores[player - 1][0] = 10 + framesum
      puts "line #{__LINE__} - strike in first frame"
    else
      @game_scores[player - 1][0] = 10 + @frame_scores[player - 1][1][0]
      puts "line #{__LINE__} - spare in first frame"
    end
    
  else
    if @frame_scores[player - 1][i - 1][0] == 10
        if i == 9 
          @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + @frame_scores[player - 1][i][0] + @frame_scores[player - 1][i][1]      
          print "line #{__LINE__} - stk9not10:\t#{@game_scores[player - 1].inspect}\n"
        else
          @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + framesum
          print "line #{__LINE__} - strike prev: #{@game_scores[player - 1].inspect}\n"
        end
    else
      @game_scores[player - 1][-1] = @game_scores[player - 1][-2] + 10 + @frame_scores[player - 1][i][0]
      puts "line #{__LINE__} - spare prev:  #{@game_scores[player - 1].inspect}\n"
    end
  end

end


# this is not tied to @frame_no; has to be iterated by separate loop at end
# only augments score array for first case; otherwise done in tally_comp
#
def score_complete(i)		
  if i == 9								# last frame
    frame_score = @frame_scores[player - 1][i].reduce(:+)
    # puts frame_score
    # puts @game_scores[player - 1][-1]
    @game_scores[player - 1] << @game_scores[player - 1][-1] + frame_score
		
  elsif i == 8 && @frame_scores[player - 1][i][0] == 10		# strike in 9th frame ->>  take first two of 10th
    tally_comp(i,0,i+1,0,i+1,1)
				
  else
    if @frame_scores[player - 1][i][0] == 10				# strike in current frame
      if @frame_scores[player - 1][i+1][0] == 10		# followed by strike in next frame
        tally_comp(i,0,i+1,0,i+2,0)
      else							# followed by anything else
        tally_comp(i,0,i+1,0,i+1,1)
      end
    elsif @frame_scores[player - 1][i].reduce(:+) == 10	# spare in current frame
      tally_comp(i,0,i,1,i+1,0)
    else								# no bonus
      tally_comp(i,0,i,1,nil,nil)
    end
  end
end


def tally_comp(f_ind1,r_ind1,f_ind2,r_ind2,f_ind3,r_ind3)
  frame_score = @frame_scores[player - 1][f_ind1][r_ind1] + @frame_scores[player - 1][f_ind2][r_ind2]		# always summing at least two frame_scores
    unless f_ind3.nil? == true										# need this way b/c nil values break addition
      frame_score += @frame_scores[player - 1][f_ind3][r_ind3]
    end
  @game_scores[player - 1] << frame_score
      # print "\n* #{f_ind1} #{r_ind1} #{f_ind2} #{r_ind2} #{f_ind3} #{r_ind3} *\n"		# for debug
    unless f_ind1 == 0		# can't use @frame_no here; ==11 via roll_master
      @game_scores[player - 1][-1] = @game_scores[player - 1][-1] + @game_scores[player - 1][-2] 
    end
end


# Run complete set of rolls, then score on line-by-line basis

# @frame_scores = Array.new
# @game_scores = Array.new
  gamecount = 1
# perfect = false

until gamecount == 2
  
  newgame
  getplayers

  until @frame_no == 11
    roll(@player)	
  end
  puts
  puts "diff = #{@testsum}"
  puts
  (0...@players.length).each { |i| puts @frame_scores[i].inspect, @game_scores[i][-1], "\n" }
  puts
 
  # SET ASIDE CHECKSUM WHILE FILLING ARRAYS CORRECTLY
  # progtotal = @game_scores[player - 1][-1]

  # @game_scores = Array.new    # reset for second method

  # 10.times do |i| 
  # # puts i		# yes, from 0 to 9
	# score_complete(i) 
    # print @frame_scores[player - 1][i].inspect, "\t", @game_scores[player - 1][i].inspect, "\t", @game_scores[player - 1][-1].inspect, "\n"
  # end

  # checksum = progtotal - @game_scores[player - 1][-1]
  # puts 
  # puts checksum
  
# if @game_scores[-1] == 300		# um, don't run in this form unless you mean it
#   perfect = true
# end

 gamecount += 1
 puts gamecount
# @frame_scores = Array.new
# @game_scores = Array.new
# @roll_type = 1
# @frame_no = 1
# @pins_remaining = 10
# end

# puts "games required = #{gamecount}"	
end