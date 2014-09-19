# Bowling simulator for single player with random result on each roll
# Works by scoring game *after* all rolls have been completed
#		i.e. it can't score a game-in-progress b/c working forward from each frame, not backward

# ===========================================

# methods: roll, roll_results(called by roll), score_master, tally(called by score_master)

# need following variables 

@roll_no = 1
@frame_no = 1
@pins_remaining = 10							# deal with multiple players later

@frame_scores = Array.new
@game_scores = Array.new

def roll					                    # add player as argument later
		# puts
		# puts "f#{@frame_no} r#{@roll_no}:"	# useful in design --> omitting now that score can handle output

	if @roll_no == 1
		roll_results(@roll_no - 1)		# calling roll_r(0)

		if @pins_remaining == 0 and @frame_no == 10    # using pins_rem b/c better for 2nd roll below...
			@roll_no = 3							   # this is used for 1st bonus after strike only
			@pins_remaining = 10
		elsif @pins_remaining == 0
			# score			# can't call here (or places below) w/ current score method - needs inverse
			@frame_no += 1
			@pins_remaining = 10 
		else
			@roll_no = 2
		end
		
	elsif @roll_no == 2  
		roll_results(@roll_no - 1)		# # calling roll_r(1)
		
		if @pins_remaining == 0 and @frame_no == 10    # using pins_rem covers spare and strike here
			@roll_no = 4							   # spare sends to final (3rd) bonus roll
			@pins_remaining = 10
		else
			# score
			@frame_no += 1 
			@roll_no = 1 
			@pins_remaining = 10 
		end

	elsif @roll_no == 3    				# this is 1st bonus after 10th frame strike, so array index always =1
		roll_results(1)			        # --> means always going to have 3rd roll
		if @pins_remaining == 0
			@pins_remaining == 10
		end		
		@roll_no = 4
			# don't increment frame here because always passes to another roll
		
	else						# only for roll = 4, which is always 3rd/10th
		roll_results(2)
		@frame_no += 1
	
	
		# if @pins_remaining == 0
			# @roll_no = 4
			# @pins_remaining = 10		# think this was missing before....
		# else
			# @roll_no = 5
		# end
		# # don't increment frame here because always passes to another roll
	
	# elsif @roll_no == 4 				# used for 3rd frame after spare OR strike
		# roll_results(2)
		# # score
		# @frame_no += 1
		
	# else								# should only call if roll=5
		# roll_results(2)
		# # score
		# @frame_no += 1
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


def score_master(i)		# frame_no --> i  ;   this will run once per roll, but requires that all rolls have happened
	if i == 9								# last frame
		frame_score = @frame_scores[i].reduce(:+)
		@game_scores << @game_scores[-1] + frame_score
		
	elsif i == 8 && @frame_scores[i][0] == 10		# strike in 9th frame ->>  take first two of 10th
		tally(i,0,i+1,0,i+1,1)
				
	else
		if @frame_scores[i][0] == 10				# strike in current frame
			if @frame_scores[i+1][0] == 10		# followed by strike in next frame
				tally(i,0,i+1,0,i+2,0)
			else							# followed by anything else
				tally(i,0,i+1,0,i+1,1)
			end
		elsif @frame_scores[i].reduce(:+) == 10	# spare in current frame
			tally(i,0,i,1,i+1,0)
		else								# no bonus
			tally(i,0,i,1,nil,nil)
		end
	end
end


def tally(f_ind1,r_ind1,f_ind2,r_ind2,f_ind3,r_ind3)
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
		score_master(i) 
		print @frame_scores[i].inspect, "\t", @game_scores[i].inspect, "\n"
	end

	# if @game_scores[-1] == 250
		# perfect = true
	# end

	# gamecount += 1
	# @frame_scores = Array.new
	# @game_scores = Array.new
	# @roll_no = 1
	# @frame_no = 1
	# @pins_remaining = 10
# end

# puts "games required = #{gamecount}"	
