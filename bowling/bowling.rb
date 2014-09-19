# Bowling simulator - 5th draft
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

# FOR DRAFT 5 --	Scrapping initial results array, setting up separate roll/score holders
#					roll array will have some single elements (strikes), some array elements (bonus, spares, <10)
#					and maybe: leave blank row at beginning so frame variable doesn't require subtraction?



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
# DRAFT 5 -- starting over from new results array; should be able to use length/sum of nested arrays to direct




def score()		

	print "\t", @frame_scores[@frame_no - 1].inspect
	frame_total = @frame_scores[@frame_no - 1].reduce(:+)
	#frame_prev = @frame_scores[@frame_no - 2].reduce(:+)
	# print "\t", @frame_scores[@frame_no - 2].inspect		# OKAY : this becomes @frame_scores[-1], which is a real thing but the wrong thing
	print "\t", frame_total
	
	# okay, how about this: skip the usual display patterns; keep a running total and then back-modify; no nil values
	
	if @frame_no == 1

		@game_scores << frame_total
						
	else
		   # this should be <10 following spare
		if frame_total != 10 and @frame_scores[@frame_no - 2].reduce(:+) == 10 and @frame_scores[@frame_no - 2].length == 2
		
			print "\n\tspare: ", @game_scores[-1], "/", @frame_scores[@frame_no - 1][0], "/", frame_total, "\n"
			@game_scores[-1] = @game_scores[-1]+ @frame_scores[@frame_no - 1][0]
			print "\t\t\t\t", @game_scores.inspect
			@game_scores << @game_scores[-1] + frame_total
			
		# end
		
		
		# frame_total != 10

		# if @game_scores[@frame_no - 2].nil? == true
			
			# @game_scores << frame_total	
			# print " bonus"
			
		else
			
			# puts
			# puts @frame_no
			# puts (@frame_no - 2)
			# puts ">>", @game_scores[@frame_no - 2].inspect
			@game_scores << @game_scores[-1] + frame_total


		end
	
	end

	print "\n\t\t\t\t", @game_scores.inspect
	
end



puts "------------------"
until @frame_no == 11
	roll				# once add mult players, this needs to iterate; but maybe def score so runs all at once?
	# score -- oh, this runs every roll, not every frame --> call within roll?
end
print "\n\n", @frame_scores.inspect
