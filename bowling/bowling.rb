# Bowling simulator - 4th draft
#     Starting from DL#2 via codersdojo, with mods:
#     Going to try random-generating (vs. hard coding) frame results, 
#     and setting up for skill variation (=odds variation), multiple bowlers

# FOR DRAFT 2 -- 	HAVE WORKING ROLL METHOD THAT RUNS FULL GAME FOR SINGLE RANDOM PLAYER;
#					NEXT:  NEED TO DEPOSIT ROLL RESULTS IN ARRAY, WRITE SCORE METHOD

# FOR DRAFT 3 --	HAVE RESULTS STORED IN ARRAY; LOTS OF DUPLICATE SHORT LINES BUT NOT MOVING TO SEPARATE METHODS JUST YET
#                   

# FOR DRAFT 4 --	REPEAT HIT/RECORD CODE INTO roll_results; STARTING score TO WORK WITH ARRAY
#					if want to output results frame-by-frame, score needs to be called repeatedly and work with one line at a time
#					going to follow through with initial array setup, but pretty clear all the nil vals are no good -- need two arrays for rolls/scores
#					think rolls/scores array, plus score meth branches written in terms of last_total placeholder that guides search...


# try to write as class, where # players gets picked when activating

#  so apart from how you weight the skill levels, how are those weights going to be called from a roll function?
#      also, might think about weights in terms of pins remaining, rather than just 10
#      oh, so --> roll method generates random number; player component uses *that* to return score?
#  OKAY, SO : gonna shift weighting to separate file, concentrate on getting one simple player working

#  by original prompt, need ONE roll method, one score method (runs at end)
#      --> for so want to store rolls in array and then score and print at end

# =============================================================================


# first test:  roll method that generates random 0-10 result
# second test: random roll that tracks remaining pins
# third test:  add roll_no and start branching method
#              --> this turns into working complete game (save 10th frame) really quickly
# fourth test: add bonus rolls for 10th frame (into existing flowchart)
#				strike trickier than spare;
#				WORK-AROUND: using roll_no = 3/4/5 for bonus rolls
#				cases:  strike [3] some [5] remainder;  strike [3] strike [4] 10;   some spare [4] 10;
# if refactoring, can replace 10-pin and remainder rolls with sub-methods, though each only called twice
# fifth test:  set up array to store before printing
# sixth test:  score method that adds running total to array on line-by-line basis

# =============================================================================










# need following variables:

@roll_no = 1
@frame_no = 1
@pins_remaining = 10
# deal with multiple players later

@results = Array.new
(0...10).each { |i| @results[i] = [nil, nil, nil, nil] }
puts @results.inspect


def roll_results(index)			# this is fine as long as roll method written in terms of @pins_remaining, not pins_hit (which is now local)
	
	pins_hit = rand(0..@pins_remaining)    
	print "\t#{pins_hit}"
	
	@pins_remaining = @pins_remaining-pins_hit
	# print "\t#{@pins_remaining}"			# useful for testing but not needed for final output
	
	# puts @results[@frame_no - 1].inspect
	# puts @results[@frame_no - 1][0].inspect
		
	@results[@frame_no - 1][index] = pins_hit   # math for bonus cases handled in roll method
	# puts @results.inspect 
	
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
			
			score
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
			
			score
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
		score
		@frame_no += 1
		
	else								# should only call if roll=5
		
		roll_results(2)
		score
		@frame_no += 1
	
	end
	
end


# trying to write so runs once per set of rolls, reports running total only when *not* strike/spare
# first test: if first frame isn't strike/spare, sums and adds to array; if s/s, skips
#				1st draft only works if no strikes -- otherwise probs with nil/fixnum
#				try reversing : IF first frame =10, OR sum of frames =10, do nothing for now; else...
# second test: if current frame <10 and prev frame <10 (and != nil), sums current and adds to prev
#				will score complete game *if* no strikes/spares -- any one s/s loses running total for rest of game
# third test:  get running total to reach back to last non-nil total
#				works *unless* first frame is s/s

def score()			
	
	# temp = [1, 2, 3, 4, nil, 5]
	# print "\t\t#{temp.compact.reduce(:+)}"
	
	
	
	if @results[@frame_no - 1][0] == 10 or @results[@frame_no - 1][0] + @results[@frame_no - 1][1] == 10
										#  unwieldy, but avoids asking for addition w/ nil (doesn't work)
		print "\tten or sum=ten"
		return
	
		# if strike or spare, do nothing for now
	
	else	# only here if frame != 10;  separating out first frame from running total
		
		if @frame_no == 1		# since checking prior frame below, need to separate 1st frame here
		
			@results[@frame_no - 1][3] = @results[@frame_no - 1][0] + @results[@frame_no - 1][1]
			print "\ta: #{@results[@frame_no - 1][3]}"
		
		elsif @results[@frame_no - 2][3] != nil		# this alone provides running total for game *without* any strikes/spares
		
			@results[@frame_no - 1][3] = @results[@frame_no - 1][0] + @results[@frame_no - 1][1] + @results[@frame_no - 2][3]
			print "\tb: #{@results[@frame_no - 1][3]}"
		
		else			# this kicks in if prior frame ==nil
		
			i = 2
			i += 1 until i == @frame_no or @results[@frame_no - i][3] != nil 
			
			if i == @frame_no		# means have gone back to first frame w/o finding any totals
									# don't use .compact.reduce for now, b/c know both rolls in first frame have integer
				
				print "\tc: +#{@results[@frame_no - i][0] + @results[@frame_no - i][1]} --> "
				@results[@frame_no - 1][3] = @results[@frame_no - 1][0] + @results[@frame_no - 1][1] + @results[@frame_no - i][0] + @results[@frame_no - i][1]
				print @results[@frame_no - 1][3]													   # grabbing roll scores from first frame
			
			else					# should mean found non-nil frame *before* getting back to first
			
				@results[@frame_no - 1][3] = @results[@frame_no - 1][0] + @results[@frame_no - 1][1] + @results[@frame_no - i][3]
				print "\td: #{@results[@frame_no - 1][3]}"
				
			end
		
		end
		
	end
	
end



puts "------------------"
until @frame_no == 11
	roll				# once add mult players, this needs to iterate; but maybe def score so runs all at once?
	# score -- oh, this runs every roll, not every frame --> call within roll?
end
puts
puts @results.inspect
