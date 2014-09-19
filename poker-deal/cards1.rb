#   DL #3 Card Dealer -- works with evaluation inside print method
    
	# as of 9/12 -- repeated errors in repl.it don't occur with installed ruby
	# adding option to specify #players/#cards (-until loops work to control inputs),
	#    but: hand_eval as defined isn't accurate for hands > 5 cards,
	#    so disabling (w/in print method) for those cases 
	# also adding option to deal additional hand


	
def build_deck

	# assembles master deck that gets duplicated/shuffled by deal method

    suits = %w(Club Diamond Spade Heart)
    values = %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King)

    @deck_master = Array.new
    suits.each do |suit|
        values.each do |value|
            card = [suit, value]
            @deck_master << card
		end
	end
end



def deal_cards()

	# copies/shuffles master deck, removes elements from array when dealing (using .shift)

	num_players = 0
	num_cards_per_player = 0
	
	# takes user input for cards/players, with limitations
	
	until num_players >= 2 and num_players <= 5
        puts "How many players (2-5)?"
        num_players = gets.to_i
	end 
	
	max_hand = 52/num_players    # when print this, seems like always integer
    
	until num_cards_per_player >= 1 and num_cards_per_player <= max_hand
        puts "How many cards per player (1-#{max_hand}; max 5 to score hand)?"
        num_cards_per_player = gets.to_i
    end	
	
    puts "\nDealing #{num_cards_per_player} card(s) to #{num_players} player(s)"
    puts

	# copies deck and distributes cards into new arrays
    
    deck = @deck_master.shuffle
    @hands = Array.new   

        (0...num_players).each do |i|
            @hands[i] = deck.shift(num_cards_per_player)
            # puts "hand #{i+1} = #{@hands[i].length} cards"    # for testing
            # puts @hands[i].inspect, "\n"                      # for testing 
        end

end



	# Notes on iterating through arrays w/o passing variables b/t methods:
	# As used in print_hands method below
		# tests on calling array levels:
		#    puts "#{@hands[0][0][0]} [0][0][0]"    # --> this gets suit
		#    puts "#{@hands[0][0][1]} [0][0][1]"    # --> this gets value
		#    puts "#{@hands[0][0][1].concat("%")}"  # --> works, so output=string
	# -------------------------------------------------------------
		# tests for how .length works on nested array
		#    puts @hands.inspect
		#    puts "@hands.length = #{@hands.length}"
		#    puts "@num_players = #{@num_players}"
		#    puts "@hands[0].length = #{@hands[0].length}"
		#    puts "@num_cards_per_player = #{@num_cards_per_player}"
	# -------------------------------------------------------------
		# so the inputs to deal_cards *are* encoded in array structure
		# and don't have to be pulled out as @vars if not desired;
		# disabling @vars created at end of deal_cards but leaving code 
	# -------------------------------------------------------------
		# deal_cards is written (card/player, players)
		# SECOND LEVEL LENGTH = CARDS/PLAYER
		# FIRST LEVEL LENGTH =  NO. PLAYERS
	#--------------------------------------------------------------



def print_hands()
    
	# prints cards in each hand, calls eval method to print pairs(etc.) on next line
	
    (0...@hands.length).each do |i|
        # o hai! that why the (...) option is useful - no "-1" needed
            
        print "Player #{i+1}: "
            
		(0...@hands[0].length).each do |j|

			if j < @hands[0].length-1
                print @hands[i][j].join("-"), ", "
            else
                print @hands[i][j].join("-")
            end
		
		end
           
        puts                # keep active - need to separate player hands
        # puts "\ni = #{i} --> to hand_eval"    # for testing
        
		if @hands[0].length >=2 and @hands[0].length <= 5
		
			hand_eval(i)        # works here with proper ruby install (vs. repl.it)
								# but eval method gets weird for cards>5 	
		end 
		
    end
        
    puts
    
end



def hand_eval(current_hand)
    
	# method uses one loop to count pairs, second loop to check no. of suits:
	#     *if* only dealing 5-card hands, second loop could be simpler,
	#     -- because pair/triple/4K/FH all generate unique result w/in first loop --
	#     but leaving suitcount variable for later use/expansion;
	
	
    # puts "hand_eval called here"    # for testing
    paircount = 0
    suitcount = 0
	
		# test notes from initial design
			# puts "starting hand_eval(#{current_hand}): \tplayer = #{current_hand+1}"
			# puts "\t\t\tpaircount = #{paircount}"
			# puts "\t\t\ttripcount = #{tripcount}"
			# -------------------------------------
			# puts @hands[0].inspect        # @var works fine
			# puts @hands[0].sort.inspect   # sorts by suit, alphabetically - 
			# puts @hands[1].sort.inspect   #     may not help but good to know
			# puts @hands[0][0][1]          # doublecheck way to read card value
	#
	
	
	# PAIRS loop to count value matches
    #     nested loop below uses v/v2 combo to iterate:
    #     ranges reserve array[0] for outside loop, array[-1] for inside;
    #     that way only testing each v/v2 pairing once
	#
	#     note math: b/c counting *pairs*, triple gives 3, FH->4, 4K->6
	#     means diff counting method might be needed for large hands
    
    (0...@hands[current_hand].length-1).each do |v|
    
	    # for testing:
        # puts "outer loop:\tv  *** #{v} up to #{@hands[current_hand].length-1}"

        (v+1...@hands[current_hand].length).each do |v2|
        
            # this loop: need range starting with _ v _, not spanning full array
            # set right, means no (v != v2) conditional required
		
			# for testing:
            # puts "inner loop:\tv2 *** #{v2} up to #{@hands[current_hand].length-1}"
            # print @hands[current_hand][v][1]
            # print "/", @hands[current_hand][v2][1]
            
            if @hands[current_hand][v][1] == @hands[current_hand][v2][1]

        		# outputs below used for testing
                # puts "v =#{v}\t>\t#{@hands[current_hand][v][0]} #{@hands[current_hand][v][1]}"
                # puts "v2=#{v2}\t>\t#{@hands[current_hand][v2][0]} #{@hands[current_hand][v2][1]}"

				paircount = paircount += 1

            end
            
            # puts "\tthrough inner loop "    # for testing   

        end
        
        # puts "\t through outer loop"    # for testing

    end

	
    # SUITS loop to mark flushes
    # approach: can work by negation - if #suits != 1, no flush;
    #           pull suits to new array, _uniq_ (not compact), test length
    #           nice b/c # of cards dealt irrelevant UNLESS only 1...
    #           need exit for that or will call every singleton a flush

    flush_test = Array.new

		(0...@hands[current_hand].length).each do |s|

			# puts @hands[current_hand][s][0]    # for testing - extracts suits

			flush_test << @hands[current_hand][s][0]
			# puts "\t#{flush_test.inspect}"    # for testing

		end

		# puts flush_test.inspect
		# puts flush_test.uniq.inspect
		# print flush_test.uniq.length
    
    suitcount = flush_test.uniq.length
	# puts "suitcount = #{suitcount}"    # test

	
    # output combined results of two tests
    
    print "Player #{current_hand+1}: "
    
    if suitcount == 1
		print "flush\n\n"
	elsif paircount == 6        # could add 'and suitcount == 4' for larger hands
        print "four of a kind\n\n"
	elsif paircount == 4        # could add 'and suitcount == 2' for larger hands 
        print "full house\n\n"
    elsif paircount == 3
        print "triple\n\n"
    elsif paircount == 2
        print "two pairs\n\n"
    elsif paircount == 1
        print "one pair\n\n"
    else
        print "-\n\n"
    end


end             




# run methods

puts "-------------------------------------------------"

build_deck
deal_cards
print_hands




# puts "-------------------------------------------------"
    # rigged case to check higher-value/lower-frequency deals
    # full house, four-kind and flush all working for 5-card deal
# puts
# puts @hands[0].inspect
# puts
# rigged_hand = [ [ ["Heart", "5"], ["Club", "5"], ["Heart", "3"], ["Club", "3"], ["Spade", "3"] ], [ ["Heart", "5"], ["Diamond", "3"], ["Heart", "3"], ["Club", "3"], ["Spade", "3"] ], [ ["Heart", "2"], ["Heart", "5"], ["Heart", "7"], ["Heart", "8"], ["Heart", "10"] ] ]
# puts rigged_hand[0].inspect
# puts rigged_hand[1].inspect
# puts rigged_hand[2].inspect
# @hands = rigged_hand
# puts @hands.inspect
# hand_eval(0)    # should yield full house
# hand_eval(1)    # should yield four of a kind
# hand_eval(2)    # should yield flush
