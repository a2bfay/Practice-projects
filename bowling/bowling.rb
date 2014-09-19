# Bowling simulator - second draft
#     Starting from DL#2 via codersdojo, with mods:
#     Going to try random-generating (vs. hard coding) frame results, 
#     and setting up for skill variation (=odds variation), multiple bowlers

# FOR DRAFT 2 -- 	HAVE WORKING ROLL METHOD THAT RUNS FULL GAME FOR SINGLE RANDOM PLAYER;
#					NEXT:  NEED TO DEPOSIT ROLL RESULTS IN ARRAY, WRITE SCORE METHOD


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


# =============================================================================

# need following variables:

@roll_no = 1
@frame_no = 1
@pins_remaining = 10
# deal with multiple players later


@results = Array.new

(0...10).each { |i| @results[i] = [nil, nil, nil, nil] }

puts @results.inspect

def roll()                   # add player as argument later

	puts "f#{@frame_no} r#{@roll_no}:"
    
	if @roll_no == 1

		pins_hit = rand(0..10)    
		print "\t#{pins_hit}"
	
		@pins_remaining = @pins_remaining-pins_hit
		print "\t#{@pins_remaining}\n"
	
		# puts @results[@frame_no - 1].inspect
		# puts @results[@frame_no - 1][0].inspect
		
		@results[@frame_no - 1][0] = pins_hit 
		# puts @results.inspect 
				
		if @pins_remaining == 0 and @frame_no == 10    # using pins_rem b/c better for 2nd roll below...

			@roll_no = 3							   # this is used for 1st bonus after strike only
			@pins_remaining = 10
			
		elsif pins_hit == 10
			
			@frame_no += 1
			@pins_remaining = 10 
			
		else
		    
			@roll_no = 2
			
		end
		
	elsif @roll_no == 2  

		pins_hit = rand(0..@pins_remaining)    
		print "\t", pins_hit
	
		@pins_remaining = @pins_remaining-pins_hit
		print "\t#{@pins_remaining}\n"
		
		@results[@frame_no - 1][1] = pins_hit 
		# puts @results.inspect
		
		if @pins_remaining == 0 and @frame_no == 10    # using pins_rem covers spare and strike here

			@roll_no = 4							   # spare sends to final (3rd) bonus roll
			@pins_remaining = 10
		
		else
			
			@frame_no += 1 
			@roll_no = 1 
			@pins_remaining = 10 
			
		end

	elsif @roll_no == 3    				# this is 1st bonus after 10th frame strike
	                                    # another strike sets roll=4; partial sets roll=5
										
		pins_hit = rand(0..10)    
		print "\t#{pins_hit}"
	
		@pins_remaining = @pins_remaining-pins_hit
		print "\t#{@pins_remaining}\n"
		
		@results[9][1] = pins_hit 
		puts @results.inspect
	
		if @pins_remaining == 0
			
			@roll_no = 4
		
		else
			
			@roll_no = 5
		
		end
				
		# don't increment frame here because always passes to another roll
	
	elsif @roll_no == 4 					# used for 3rd frame after spare OR strike
				
		pins_hit = rand(0..10)    
		print "\t#{pins_hit}"
		
		@pins_remaining = @pins_remaining-pins_hit
		print "\t#{@pins_remaining}\n"
		
		@results[9][2] = pins_hit 
		puts @results.inspect

				@frame_no += 1
		
	else								# should only call if roll=5
		
		pins_hit = rand(0..@pins_remaining)    
		print "\t", pins_hit
	
		@pins_remaining = @pins_remaining-pins_hit
		print "\t#{@pins_remaining}\n"
		
		@results[9][2] = pins_hit 
		puts @results.inspect

		@frame_no += 1
	
	end
	
end




puts "------------------"
until @frame_no == 11
	roll
end
