# Bowling simulator for single player with random result on each roll
# Works by scoring game *after* all rolls have been completed --> now changing
#		i.e. it can't score a game-in-progress b/c working forward from each frame, not backward
# Option at end to repeat games for stats-checking

# GIT CHECK: what happens when edit and re-save in directory? (automatic.)
#   9/18 switching to git for versions; 
#   retitling score-master and tally as complete-game methods,
#   starting game-in-progress scoring

# ===========================================

# existing methods: roll, roll_results(called by roll), score_complete, tally_comp(called by score_complete)
# adding: score_progress, tally_prog[?]

# need following variables 
#
@roll_type = 1
@frame_no = 1
@pins_remaining = 10							# deal with multiple players later

@frame_scores = Array.new
@game_scores = Array.new

def roll					                    # add player as argument later
	
  if @roll_type == 4					# only for 10th/3rd
    roll_results(2)
    @frame_no += 1
		
  elsif @roll_type == 3					# only for 1st bonus after 10th frame strike, so array index always =1
    roll_results(1)			        # --> means always going to have 3rd roll
      if @pins_remaining == 0
        @pins_remaining == 10
      end		
      @roll_type = 4
        # don't increment frame here because always passes to another roll

  else
    roll_results(@roll_type - 1)		# should work for 1st or 2nd roll
	
    if @roll_type == 1

      if @pins_remaining == 0 and @frame_no == 10    # 10th fr strike
        @roll_type = 3							   # --> to 1st bonus after strike
        @pins_remaining = 10
      elsif @pins_remaining == 0
        @frame_no += 1
        @pins_remaining = 10 
      else
        @roll_type = 2
      end
		
    elsif @roll_type == 2  
			
      if @pins_remaining == 0 and @frame_no == 10    # using pins_rem covers spare and strike here
        @roll_type = 4							   # spare sends to final (3rd) bonus roll
        @pins_remaining = 10
      else
        @frame_no += 1 
        @roll_type = 1 
        @pins_remaining = 10 
      end
    end
  end
end


def roll_results(index)						# requires roll method written in terms of @pins_remaining, not pins_hit (which is now local)
  pins_hit = rand(0..@pins_remaining)    
    # print "\t#{pins_hit}"					# for testing --> final output to score method
  @pins_remaining = @pins_remaining - pins_hit
    # print "\t#{@pins_remaining}"			# useful for testing but not needed for final output
  if index == 0 
    @frame_scores << [pins_hit]   		# math for bonus cases handled in roll method
  else 
    @frame_scores[@frame_no - 1] << pins_hit
  end
    # print "\t", @frame_scores.inspect # for testing
end


# works frame by frame; means never looks forward, also never has to look back >3 frames
# for now, plan on calling w/in roll as score_progress(@frame_no - 1)
#
def score_progress(i)
  framesum = @frame_scores[i].reduce(:+)
  
  # need these? or want for legibility?
  #
  unless i == 0
    frameprev = @frame_scores[i - 1].reduce(:+)
  end
  unless i <= 1
    frame2prev = @frame_scores[i - 2].reduce(:+)
  end

    # is this frame a bonus? if so, need nil as placeholder?
    # *all* other cases assume frame tot < 10     --> except 10th frame <--
    #
  if framesum == 10
    @game_scores << nil
    
    # is it the first frame? if so, frametot-->scoretot
    # don't have to worry about going past beginning of array
    #
  elsif i == 0
    @game_scores << framesum
    
    # if prev frame has total - no bonus in effect - add current to previous	
    #
  elsif @game_scores[-1].nil? == false
    @game_scores << @game_scores[i - 1] + framesum

  else  
      # remaining cases all assume nil/bonus in prev frame:
      # don't need to recheck, but type of bonus matters; 
      # so does 2prev frame (in every subcase? -- no)
      #
      # start here b/c two nils in a row can only happen with two strikes
      # gaaaah this will require an exception for early frames, won't it?
      #
    if @game_scores[-2].nil? == true
      @game_scores[-2] = @game_scores[-3] + 20 + @frame_scores[i][0]
        # don't forget to append current...
 
       # down to either strike or spare on prev frame
       # treat strike next
       #
    elsif @frame_scores[i - 1][0] == 10 
      @game_scores[-1] = @game_scores[-2] + 10 + framesum
      
      # leaves spare on prev frame
      #
    else
      @game_scores[-1] = @game_scores[-2] + 10 + @frame_scores[i][0]
      ####  RESUME HERE
    end
  
  end

end


# this is not tied to @frame_no; has to be iterated by separate loop at end
# only augments score array for first case; otherwise done in tally_comp
#
def score_complete(i)		
  if i == 9								# last frame
    frame_score = @frame_scores[i].reduce(:+)
    @game_scores << @game_scores[-1] + frame_score
		
  elsif i == 8 && @frame_scores[i][0] == 10		# strike in 9th frame ->>  take first two of 10th
    tally_comp(i,0,i+1,0,i+1,1)
				
  else
    if @frame_scores[i][0] == 10				# strike in current frame
      if @frame_scores[i+1][0] == 10		# followed by strike in next frame
        tally_comp(i,0,i+1,0,i+2,0)
      else							# followed by anything else
        tally_comp(i,0,i+1,0,i+1,1)
      end
    elsif @frame_scores[i].reduce(:+) == 10	# spare in current frame
      tally_comp(i,0,i,1,i+1,0)
    else								# no bonus
      tally_comp(i,0,i,1,nil,nil)
    end
  end
end


def tally_comp(f_ind1,r_ind1,f_ind2,r_ind2,f_ind3,r_ind3)
  frame_score = @frame_scores[f_ind1][r_ind1] + @frame_scores[f_ind2][r_ind2]		# always summing at least two frame_scores
    unless f_ind3.nil? == true										# need this way b/c nil values break addition
      frame_score += @frame_scores[f_ind3][r_ind3]
    end
  @game_scores << frame_score
      # print "\n* #{f_ind1} #{r_ind1} #{f_ind2} #{r_ind2} #{f_ind3} #{r_ind3} *\n"		# for debug
    unless f_ind1 == 0		# can't use @frame_no here; ==11 via roll_master
      @game_scores[-1] = @game_scores[-1] + @game_scores[-2] 
    end
end


# Run complete set of rolls, then score on line-by-line basis

# @frame_scores = Array.new
# @game_scores = Array.new
# gamecount = 1
# perfect = false

# until perfect == true

  until @frame_no == 11
    roll	
  end

  10.times do |i| 
    # puts i		# yes, from 0 to 9
	score_complete(i) 
    print @frame_scores[i].inspect, "\t", @game_scores[i].inspect, "\n"
  end

# if @game_scores[-1] == 300		# um, don't run in this form unless you mean it
#   perfect = true
# end

# gamecount += 1
# @frame_scores = Array.new
# @game_scores = Array.new
# @roll_type = 1
# @frame_no = 1
# @pins_remaining = 10
# end

# puts "games required = #{gamecount}"	
