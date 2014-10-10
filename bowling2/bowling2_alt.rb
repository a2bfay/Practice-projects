# 9 Oct. --> TESTING ALTERNATE OBJECT DEFINITIONS; removing notes-to-self for easier reading

# BOWLING SIMULATOR WITH SCORING DONE FRAME-BY-FRAME (vs. 'kata' version)
  # crux of trouble so far:  a LANE_GAME is built out of turns, but a PLAYER_GAME is built out of consecutive frames, w/ scores
  # should frame data get stored in PLAYER?  that would require TURN to distribute FRAMES among PLAYERS

# ---- MESSAGES ----
# who's playing?
# what frame are we in?
# whose turn is it?
# what roll result/frame result? --> how good is player?
# what's the current score? --> who's the current leader?
# is the game over?
# who won?

# Getting rid of : RollCalc / Frame / Player / Turn / Game
# In favor of : Player / Frame / PlayerGame / Game
  
# ================================================================================
puts; puts


# ---------------------------------------------------------
# returns up to two weighted random rolls from 10 initial pins
# data: skill / behavior: rolls generated according to skill
class Player
  attr_reader :skill            # calculation methods can be invisible; skill would be useful for screen output 
  def initialize(skill = 0)
    raise RangeError unless skill >= 0
    @skill = skill
  end
    
  def roll
    reset_lane
    weighted_roll(@pins_standing)
    @results
  end
  
  private  
  
  def reset_lane
    @roll_no = 1
    @pins_standing = 10
    @results = []
  end

  def update_lane(pins_hit)
    @roll_no += 1
    @pins_standing -= pins_hit
  end
  
  def weighted_roll(pins)
    pins_hit = apply_skill(pins)
    @results << pins_hit
    update_lane(pins_hit)
    weighted_roll(@pins_standing) unless pins_hit == 10 || @roll_no > 2
  end
  
  def apply_skill(pins)
    picks = []
    (@skill + 1).times { picks << rand(0..pins)
                         break if picks.max == pins }
    picks.max
  end
end

# picks = []
    # (@skill + 1).times do
      # pick = rand(0..pins)
      # picks << pick
      # break if pick == pins
    # end
    # picks.max

player1 = Player.new
puts player1.skill
puts player1.roll.inspect
puts 

player2 = Player.new 15
puts player2.skill
puts player2.roll.inspect
puts 


# ---------------------------------------------------------
# stores/evaluates set of rolls in single array
class Frame
  attr_reader :results             # read only; avoid accessor
 
  def initialize(player)
    @results = player.roll         # so this is an actual injection; no longer knows class, just response
  end                              # but means doubles are be necessary for tests
  
  def first_roll
    @results[0]
  end
  
  def second_roll
    @results[1] # this doesn't appear to require an 'unless' -- simply returns nil if nothing there
  end           # could add boolean second_roll? but don't see value yet
    
  def total
    @results.reduce(:+)
  end

  def strike?
    @results[0] == 10
  end
  
  def spare?
    strike? == false && total == 10
  end
end

frame1 = Frame.new (player1)
puts "frame1:\t#{frame1.results}"


# going to initialize with Player, not with skill setting
# does not need to know that player can .roll --> that responsibility to Frame
class PlayerGame
  attr_reader :player, :frames, :scores
  def initialize(player) 
    @player = player
    @frames = []
    @scores = []
  end
  
  def take_turn
    bowl
    score_turn
  end

  def frame(num)
    @frames[num - 1]
  end

  def frame_results(num)
    frame(num).results
  end
  
  def frames_played
    @frames.map { |fr| fr.results }
  end
    
  private
  
  def bowl
    player_frame = Frame.new (@player)     # pass Frame object into variable, not Frame.results
    @frames << player_frame                # do the same here? --> YES. makes Frame methods available elsewhere
  end
  
  def score_turn
    # create new scoring window, sending it up to last 3 frames
  end
end

game1 = PlayerGame.new (player1)
3.times { game1.take_turn }
puts "game1:\t#{game1.frames_played}"

game2 = PlayerGame.new (player2)
3.times { game2.take_turn }
puts "game2:\t#{game2.frames_played}"


# class GameTurn
  # def initialize(players)
    # @players = players
    # @players.each { |player| player.take_turn }
  # end
# end



# # works for the moment (but with new Players generated during initialization)
# #   with UI code in place, should be able to initialize with set of skilled players instead
# class Game
  # attr_reader :players # :winner 
  # def initialize(players)
    # @players = players
    # play_game
  # end
  
  # private
  
  # def play_game
    # 10.times { GameTurn.new(@players) }
  # end
# end



# # user input here for now
# def input_player_settings
  # print "How many players(1-4)?  "
    # numplayers = gets.chomp.to_i
    # numplayers = 1 if numplayers < 1
    # numplayers = 4 if numplayers > 4
  
  # @input_players = []
  # puts "Enter skill level 0-15 (2+ = good, 4+ = v.good, 6+ = pro):"
  # (1..numplayers).each do |p|
    # print "Skill level for player #{p}?  "
    # skill = gets.chomp.to_i
    # skill = 0 if skill < 0
    # @input_players << Player.new(skill)
  # end
# end



# # runs/prints one game
    # input_player_settings
    # game = Game.new(@input_players)
    # players_final = game.players
    # players_final.each { |player| puts player.frames_played.inspect }



# # ===================================================================================================================================================================
# # METZ "test everything just once and in the proper place"
# # "This choice between injecting real or fake objects has far-reaching consequences.
# # Injecting the same objects at test time as are used at runtime ensures that tests break
# # correctly but may lead to long running tests. Alternatively, injecting doubles can speed
# # tests but leave them vulnerable to constructing a fantasy world where tests work but
# # the application fails."

# require "test/unit"

# class TestRollCalc < Test::Unit::TestCase
  # def test_roll_limits
    # roll = RollCalc.new
    # assert roll.results.max <= 10
    # assert roll.results.min >= 0
  # end
  
  # def test_roll_sum
    # roll = RollCalc.new
    # assert roll.results.reduce(:+).between? 0, 10
  # end
    
  # def test_roll_sum_skill
    # skill = 15
    # roll = RollCalc.new(skill)
    # assert roll.results.reduce(:+).between? 0, 10
  # end
# end


# # these doubles provide deterministic cases for testing Frame
# class StrikeDouble
  # def results
    # [10]
  # end
# end

# class SpareDouble
  # def results
     # [2,8]
  # end
# end

# class OpenFrameDouble
  # def results
    # [3,4]
  # end
# end


# # Frame only knows that the object passed to it responds to results
# class TestFrame < Test::Unit::TestCase
  # def test_first_roll
    # frame = Frame.new OpenFrameDouble.new
    # assert frame.first_roll == 3
  # end
  
  # def test_second_roll
    # frame = Frame.new OpenFrameDouble.new
    # assert frame.second_roll == 4
  # end
      
  # def test_frame_total
    # frame = Frame.new OpenFrameDouble.new
    # assert frame.total == 7
  # end
  
  # def test_second_roll_nil
    # frame = Frame.new StrikeDouble.new
    # assert frame.second_roll.nil?
  # end
  
  # def test_frame_strike
    # frame = Frame.new StrikeDouble.new
    # assert frame.strike?      
  # end 
  
  # def test_frame_spare
    # frame = Frame.new SpareDouble.new
    # assert frame.spare?
  # end
# end


# # Player 


# # GameTurn only knows that the objects passed to it respond to take_turn
# #   but that's a command, not a query -- the data in each Player changes when it gets that message
# #   so is a mock going to be necessary here?
# class TestGameTurn < Test::Unit::TestCase
# end



# # =========================================================================================================
# # TEMP TESTS / OUTPUT GUIDES

# # for understanding structure of object
# def roll_tests_temp
  # puts "roll_tests line #{__LINE__}"
  # roll1 = RollCalc.new
  # puts "this is object: #{roll1}"
  # puts "this is reading result w/in object: #{roll1.results} / no change between readings: #{roll1.results}"
  # roll2 = RollCalc.new.results
  # puts "this is result of new object saved to var: #{roll2}"
  # puts
# end
# # roll_tests_temp

# def temp_roll_output_test 
  # test_rollcalc = RollCalc.new
  # puts "test_rollcalc: #{test_rollcalc}"
  # puts "test_rollcalc.results: #{test_rollcalc.results}"
  # puts
# end
# # temp_roll_output_test

# # guide to screen output from Frame when initialized with RollCalc OBJECT - not just results
# def temp_frame_tests_NEW
  # 2.times do
    # puts "Frame Skill 0"
    # test_fr = Frame.new ( RollCalc.new ) # here i'm passing in the OBJECT
    # puts test_fr.inspect
    # puts test_fr.results.inspect
    # puts test_fr.first_roll
    # puts test_fr.second_roll           # no error w/ strike, just blank
    # puts test_fr.second_roll.inspect   # yes, nil in that case
    # puts test_fr.total
    # puts test_fr.strike?
    # puts test_fr.spare?
    # puts
  # end

  # 2.times do
    # puts "Frame Skill 15"
    # test_fr = Frame.new ( RollCalc.new(15) )
    # puts test_fr.inspect
    # puts test_fr.results.inspect
    # puts test_fr.first_roll
    # puts test_fr.second_roll           # no error w/ strike, just blank
    # puts test_fr.second_roll.inspect   # yes, nil in that case
    # puts test_fr.total
    # puts test_fr.strike?
    # puts test_fr.spare?
    # puts
  # end
# end
# # temp_frame_tests_NEW

# # guide to screen output when player's @frames is an array of Frame *objects* (not just result arrays)
# def player_tests_temp
  # you = Player.new
  # me = Player.new 5
  # 3.times { you.take_turn; puts you.frames.inspect }   # can't simply drop frames.results.inspect in here
  # 3.times { me.take_turn; puts me.frames.inspect }
  # puts
  # # +1's below only because using single iterator (might otherwise be array index vs. frame no)
  # (0..2).each do |i| 
    # puts "*"
    # puts me.frames[i].inspect             # v
    # puts me.frame(i + 1)                  # this and above are almost equivalent (this line doesn't include @results
    # puts me.frames[i].results.inspect     # this and both below are exactly equivalent
    # puts me.frame(i + 1).results.inspect  # ^
    # puts me.frame_results(i + 1).inspect  # ^
    # puts me.frames[i].strike?
    # puts me.frames[i].spare?
    # puts "*"
    # puts " #{me.frames_played}"
    # puts me.frames_played                 # ok, funny: top line works just like .inspect; bottom spreads all entries on sep lines
  # end
# end
# # player_tests_temp  

# # checking execution of GameTurn by itself and as called by Game; screen outputs included
# # works for game initialized with Player objects - numplayers from UI
# def game_tests_temp
  # puts "turns"
  # alpha = Player.new
  # beta = Player.new
  # 10.times do 
    # turn = GameTurn.new [alpha, beta]
    # puts alpha.frames_played.inspect, beta.frames_played.inspect; puts
  # end

  # puts "test game"
  # input_players = []
  # (0..3).each { |skill| input_players << Player.new(skill) }
  # test_game = Game.new input_players          # this should be fixed
  # test_game.play_game
  # players = test_game.players
  # players.each { |player| puts player.frames_played.inspect }
  # puts
# end
# # game_tests_temp
