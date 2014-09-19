# okay, so -- going to write a score method that works for three hard-coded games:
# all strikes, all spares, no strikes or spares
# don't need roll() b/c not generating anything -- just arrays  --> check.

# okay, so -- when you have a uniform array of existing scores, that's easy
# harder: switching between addition modes
#			how about: take frame_no as input?  --> check.
# harder harder: making this work when subsq frames aren't already filled in  --> not yet...


# SO :  this can score a game of any kind AS LONG AS all the rolls are completed first
#		it can't score a game-in-progress b/c working forward from each frame, not backward
# TWO GOALS:  streamline this ;  rewrite as search-backward-call-in-progress


# BELOW USED IN WRITING/TESTING VERSIONS FOR HARD-CODED GAMES
# @strikes_frames = Array.new
	# 9.times { @strikes_frames << [10] }
	# @strikes_frames << [10,10,10]
# @strikes_scores = Array.new
	
# @spares_frames = Array.new
	# 9.times { @spares_frames << [9,1] }
	# @spares_frames << [9,1,9]
# @spares_scores = Array.new
	
# @inc_frames = Array.new
	# 10.times { @inc_frames << [8,1] }
# @inc_scores = Array.new
	
# puts @strikes_frames.inspect	
# puts @spares_frames.inspect
# puts @inc_frames.inspect


def score_strikes()

	(0..9).each do |i|
		
		if i == 0	#frame 1
		
			print "\nf#{i + 1}:\t"
			print @strikes_frames[i][0], "\t"
			frame_score = @strikes_frames[i][0] + @strikes_frames[i+1][0] + @strikes_frames[i+2][0]
			@strikes_scores <<  frame_score
			print @strikes_scores[i]
		
		elsif i >=1 and i <= 7	#frames 2-8
		
			print "\nf#{i + 1}:\t"
			print @strikes_frames[i][0], "\t"
			frame_score = @strikes_frames[i][0] + @strikes_frames[i+1][0] + @strikes_frames[i+2][0]
			@strikes_scores <<  ( @strikes_scores[i - 1] + frame_score )
			print @strikes_scores[i]
		
		elsif i == 8	#frame 9
					
			print "\nf#{i + 1}:\t"
			print @strikes_frames[i][0], "\t"
			frame_score = @strikes_frames[i][0] + @strikes_frames[i+1][0] + @strikes_frames[i+1][1]
			@strikes_scores <<  ( @strikes_scores[i - 1] + frame_score )
			print @strikes_scores[i]
			
		else	# should mean i == 9
			
			print "\nf#{i + 1}:\t"
			print @strikes_frames[i][0], "\t"
			frame_score = @strikes_frames[i][0] + @strikes_frames[i][1] + @strikes_frames[i][2]
			@strikes_scores <<  ( @strikes_scores[i - 1] + frame_score )
			print @strikes_scores[i]
			
		end
		
	end

	puts 
	puts @strikes_scores.inspect
	
end


def score_spares()

	(0..9).each do |i|
		
		if i == 0	#frame 1
		
			print "\nf#{i + 1}:\t"
			print @spares_frames[i][0], ", ", @spares_frames[i][1], "\t"
			frame_score = @spares_frames[i][0] + @spares_frames[i][1] + @spares_frames[i+1][0]
			@spares_scores <<  frame_score
			print @spares_scores[i]
			
		elsif i >= 1 and i <= 8
			
			print "\nf#{i + 1}:\t"
			print @spares_frames[i][0], ", ", @spares_frames[i][1], "\t"
			frame_score = @spares_frames[i][0] + @spares_frames[i][1] + @spares_frames[i+1][0]
			@spares_scores <<  @spares_scores[i-1] + frame_score
			print @spares_scores[i]

		else	# i=9 -> 10th frame
			
			print "\nf#{i + 1}:\t"
			print @spares_frames[i][0], ", ", @spares_frames[i][1], ", ", @spares_frames[i][2], "\t"
			frame_score = @spares_frames[i][0] + @spares_frames[i][1] + @spares_frames[i][2]
			@spares_scores <<  @spares_scores[i-1] + frame_score
			print @spares_scores[i]
			
		end
		
	end

	puts
	puts @spares_scores.inspect
	
end


def score_inc()

	(0..9).each do |i|
		
		if i == 0	#frame 1
		
			print "\nf#{i + 1}:\t"
			print @inc_frames[i][0], ", ", @inc_frames[i][1], "\t"
			frame_score = @inc_frames[i][0] + @inc_frames[i][1]
			@inc_scores <<  frame_score
			print @inc_scores[i]
			
		else
			
			print "\nf#{i + 1}:\t"
			print @inc_frames[i][0], ", ", @inc_frames[i][1], "\t"
			frame_score = @inc_frames[i][0] + @inc_frames[i][1]
			@inc_scores << @inc_scores[i-1] + frame_score
			print @inc_scores[i]

		end
		
	end

	puts
	puts @inc_scores.inspect
	
end


@frames = Array.new
@scores = Array.new

def score_master(i)		# frame_no --> i  ;   this will run once per roll, but requires that all rolls have happened

	# print "\nf#{i + 1}:\t"

	# CASE: FIRST FRAME (always diff b/c no prior total)  -->  this b/c of running total; way to option out for shorter method?
	#						what about @scores << @scores[-1] first, then @scores = @scores + frame_score?
	if i == 0			
	
		if @frames[i][0] == 10	# if strike in first frame
		
			if @frames[i+1][0] == 10	# followed by strike in next frame
				
				# NEXT TWO FIRST ROLLS
				frame_score = @frames[i][0] + @frames[i+1][0] + @frames[i+2][0]	# doesn't matter whether strike or not - just adding
				@scores << frame_score
			
			else	# doesn't matter whether spare - taking both for bonus
			
				# NEXT FRAME BOTH
				frame_score = @frames[i][0] + @frames[i+1][0] + @frames[i+1][1]
				@scores << frame_score
			
			end
						
		elsif @frames[i].reduce(:+) == 10		# if spare in first frame
		
			# NEXT FRAME FIRST ROLL 
			frame_score = @frames[i][0] + @frames[i][1] + @frames[i+1][0]
			@scores << frame_score
		
		else	# no bonus for first frame
		
			# NO BONUS
			frame_score = @frames[i][0] + @frames[i][1]
			@scores << frame_score							
			
		end
	
	# CASE: MIDDLE FRAMES  -->  identical w/ above **except for running total**
	elsif i <=7
	
		if @frames[i][0] == 10	# if strike in current frame
		
			if @frames[i+1][0] == 10	# followed by strike in next frame
				
				# NEXT TWO FIRST ROLLS
				frame_score = @frames[i][0] + @frames[i+1][0] + @frames[i+2][0]	# doesn't matter whether strike or not - just adding
				@scores << @scores[-1] + frame_score
			
			else	# doesn't matter whether spare - taking both for bonus
				
				# NEXT FRAME FIRST ROLL
				frame_score = @frames[i][0] + @frames[i+1][0] + @frames[i+1][1]
				@scores << @scores[-1] + frame_score
			
			end
						
		elsif @frames[i].reduce(:+) == 10		# if spare in first frame
		
			# NEXT FRAME FIRST ROLL
			frame_score = @frames[i][0] + @frames[i][1] + @frames[i+1][0]
			@scores << @scores[-1] + frame_score
		
		else	# no bonus for first frame
		
			# NO BONUS
			frame_score = @frames[i][0] + @frames[i][1]
			@scores << @scores[-1] + frame_score
			
		end
	
		# can i still get to frame_score outside this loop?  YES
		# puts ">>>>>>>>>>>>#{frame_score}<<<<<<<<<<"
	
	elsif i == 8		# requires changes only for strike
	
		if @frames[i][0] == 10	# strike in 9th frame  ->>  means take first two of 10th no matter what
		
				# ALL THREE ROLLS
				frame_score = @frames[i][0] + @frames[i+1][0] + @frames[i+1][1]
				@scores << @scores[-1] + frame_score
								
		elsif @frames[i].reduce(:+) == 10		# spare in first frame
		
			
			frame_score = @frames[i][0] + @frames[i][1] + @frames[i+1][0]
			@scores << @scores[-1] + frame_score
		
		else	
		
			frame_score = @frames[i][0] + @frames[i][1]
			@scores << @scores[-1] + frame_score
			
		end
		
	else	# this should always be 10th frame, i==9
		
		frame_score = @frames[i].reduce(:+)
		@scores << @scores[-1] + frame_score
				
	end

end

# BELOW USED IN TESTING HARD-CODED GAMES AT FIRST
# score_strikes

# @frames = @strikes_frames
# 10.times { |i| score_master(i) }
# puts "> > > > >"
# puts @scores.inspect

# score_spares

# @scores = Array.new
# @frames = @spares_frames
# 10.times { |i| score_master(i) }
# puts "> > > > >"
# puts @scores.inspect

# score_inc

# @scores = Array.new
# @frames = @inc_frames
# 10.times { |i| score_master(i) }
# puts "> > > > >"
# puts @scores.inspect

# ==========================================================================================================================

# need following variables:

@roll_no = 1
@frame_no = 1
@pins_remaining = 10
# deal with multiple players later

@frame_scores = Array.new
@game_scores = Array.new
#(0...10).each { |i| @frame_scores[i] = [nil, nil, nil, nil] }
puts @frame_scores.inspect
puts @game_scores.inspect


def roll_results(index)			# this is fine as long as roll method written in terms of @pins_remaining, not pins_hit (which is now local)
	
	pins_hit = rand(0..@pins_remaining)    
	print "\t#{pins_hit}"
	
	@pins_remaining = @pins_remaining-pins_hit
	# print "\t#{@pins_remaining}"			# useful for testing but not needed for final output
	
	if index == 0 
		
		@frame_scores << [pins_hit]   # math for bonus cases handled in roll method
	
	else 
	
		@frame_scores[@frame_no - 1] << pins_hit

	end
		
	# print "\t", @frame_scores.inspect 
	
end


def roll()                   # add player as argument later
	
	puts
	puts "f#{@frame_no} r#{@roll_no}:"
    
	if @roll_no == 1

		roll_results(@roll_no - 1)
				
		if @pins_remaining == 0 and @frame_no == 10    # using pins_rem b/c better for 2nd roll below...

			@roll_no = 3							   # this is used for 1st bonus after strike only
			@pins_remaining = 10
			
		elsif @pins_remaining == 0
			
			# score
			@frame_no += 1
			@pins_remaining = 10 
			
		else
		    
			@roll_no = 2
			
		end
		
	elsif @roll_no == 2  

		roll_results(@roll_no - 1)
		
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
	                                    # another strike sets roll=4; partial sets roll=5

		roll_results(1)		
		
		if @pins_remaining == 0
			
			@roll_no = 4
		
		else
			
			@roll_no = 5
		
		end
				
		# don't increment frame here because always passes to another roll
	
	elsif @roll_no == 4 					# used for 3rd frame after spare OR strike

		roll_results(2)
		# score
		@frame_no += 1
		
	else								# should only call if roll=5
		
		roll_results(2)
		# score
		@frame_no += 1
	
	end
	
end


2.times { puts "------------------" }
until @frame_no == 11
	roll	
end
#print "\n\n", @frame_scores.inspect

puts
puts

@scores = Array.new
@frames = @frame_scores

10.times do |i| 
	score_master(i) 
	print @frames[i].inspect, "\t", @scores[i].inspect, "\n"
end


# puts "> > > > >"
# puts @scores.inspect
