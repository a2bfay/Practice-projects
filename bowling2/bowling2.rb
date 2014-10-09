# METZ:
# "The knowledge that rims are at [0] should not be duplicated; it should be known in just one place."
# "these few lines of code are a minor inconvenience compared to the permanent cost of repeatedly indexing into a complex array"
# "If you rephrase every one of [a class's] methods as a question, asking the question ought to make sense."

# BOWLING SIMULATOR WITH SCORING DONE FRAME-BY-FRAME (vs. 'kata' version)
# second attempt - trying to design by proper classes/object-orientation
#   edit: building as skill/multiplayer from outset - not nec. easier to do otherwise
# but:  first thought -
# the basic units/tasks here might be:
#   roll / select result from input range
#   frame / store some number of rolls, give total/bonus
#     frame-tenth / same, w/ special cases
#   player-turn / create and fill one frame
#   player-game / link ten frames to represent complete game
#   player / (only need if skill or if multiple? not sure)
#   game / directs turns/games and evaluate scores/winners

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

# FRAME VS ROLLCALC (as opposed to Roll) SPLIT COMES OUT OF TESTING NEEDS. DOES THAT MAKE SENSE?
# trying to avoid accessors where only readers belong; also avoiding conditions within unit tests

# 8 Oct - OKAY, SO : keep passing the problem up a level; can hard-test Frame, but not Player
# as written, something else needs to know that players bowl --> asking for HOW
# should i be injecting the actual objects, rather than just properties/results?
# --> first revision -- have fixed injection so Frame gets actual RollCalc object as argument, not just results of roll
#                       but tests busted and will need double to get working
#                       also need to rework Player as a result...
# --> second revision - DOUBLES CREATED/TESTS WORKING
#

  
# ================================================================================


puts; puts


# ---------------------------------------------------------
# returns up to two weighted random rolls from 10 initial pins
class RollCalc
  attr_reader :results  

  def initialize(skill = 0)  #add player skill here later?
    raise RangeError unless skill >= 0
    @skill = skill
    @roll_no = 1
    @pins_standing = 10
    @results = []
    weighted_roll(@pins_standing)
  end
  
  private
  
  def weighted_roll(pins)
    picks = []
    (@skill + 1).times do 
      pick = rand(0..pins)
      picks << pick
      break if pick == pins
    end
    pins_hit = picks.max
    @results << pins_hit
    @roll_no += 1
    @pins_standing -= pins_hit
    weighted_roll(@pins_standing) unless pins_hit == 10 || @roll_no > 2
  end
  
# BECAUSE UNIT-TESTING CURRENT VERSION OF FRAME IS TRICKY:
# am I sure sure that roll is a class? because for now roll doesn't 'implement new_roll', it implements *result* -- which isn't really implementing anything
# should it be Lane? or Roller? so that instead of Roll.new.result (where result is just a reader),
# you would inject Roller.new, and expect it to implement roll and roll(pins)?
# except at that point, Roller sounds an awful lot like what you'd call a "frame" in actual bowling --
# its data consists of pins, and its behavior consists of hitting/counting them
 end

def temp_roll_output_test 
  test_rollcalc = RollCalc.new
  puts "test_rollcalc: #{test_rollcalc}"
  puts "test_rollcalc.results: #{test_rollcalc.results}"
  puts
end
temp_roll_output_test


# METZ: "Gear no longer cares about the class of the injected object, it merely expects that it implement diameter."
# ---------------------------------------------------------
# stores a set of rolls in an array
class Frame
  attr_reader :results             # trying to avoid accessor
 
  def initialize(roll_calc)
    @results = roll_calc.results   # so this should be an actual injection; no longer knows class, just response
  end                              # but means double may be necessary for test
  
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
# 10th frame with [10, 0, 10] and [10, 0, 0] will be good test cases...
class FrameTen < Frame  # a full, unique frame might not be best way to handle this...save for now
    
  def spare?  # good for testing override; but would this ever be necessary?
    strike? == false && (@frame[0] + @frame[1]) == 10
  end
end


def temp_frame_tests_OLD
  2.times do
    puts "Frame Skill 0"
    test_fr = Frame.new ( RollCalc.new.results ) # here i'm passing in the OUTPUT. if you write so you're passing in the actual calcuator, how do you test?
    puts test_fr.inspect
    puts test_fr.results.inspect
    puts test_fr.first_roll
    puts test_fr.second_roll           # no error w/ strike, just blank
    puts test_fr.second_roll.inspect   # yes, nil in that case
    puts test_fr.total
    puts test_fr.strike?
    puts test_fr.spare?
    puts
  end

  2.times do
    puts "Frame Skill 15"
    test_fr = Frame.new ( RollCalc.new(15).results )
    puts test_fr.inspect
    puts test_fr.results.inspect
    puts test_fr.first_roll
    puts test_fr.second_roll           # no error w/ strike, just blank
    puts test_fr.second_roll.inspect   # yes, nil in that case
    puts test_fr.total
    puts test_fr.strike?
    puts test_fr.spare?
    puts
  end
end
#temp_frame_tests_OLD


# this works fine but screws up existing tests --> are those going to require doubles (that respond to .results)?
def temp_frame_tests_NEW
  2.times do
    puts "Frame Skill 0"
    test_fr = Frame.new ( RollCalc.new ) # here i'm passing in the OBJECT
    puts test_fr.inspect
    puts test_fr.results.inspect
    puts test_fr.first_roll
    puts test_fr.second_roll           # no error w/ strike, just blank
    puts test_fr.second_roll.inspect   # yes, nil in that case
    puts test_fr.total
    puts test_fr.strike?
    puts test_fr.spare?
    puts
  end

  2.times do
    puts "Frame Skill 15"
    test_fr = Frame.new ( RollCalc.new(15) )
    puts test_fr.inspect
    puts test_fr.results.inspect
    puts test_fr.first_roll
    puts test_fr.second_roll           # no error w/ strike, just blank
    puts test_fr.second_roll.inspect   # yes, nil in that case
    puts test_fr.total
    puts test_fr.strike?
    puts test_fr.spare?
    puts
  end
end
temp_frame_tests_NEW


# class Player
  # attr_reader :skill, :frames
  
  # def initialize(skill = 0)
    # @skill = skill
    # @frames = []
    # @scores = []
  # end
  
  # def bowl
    # player_frame = Frame.new ( RollCalc.new(@skill).results )   # have to pass results, not object
    # puts "* #{player_frame.results}"
    # @frames << player_frame.results
  # end
# end

# you = Player.new
# me = Player.new 5
# 3.times do 
  # you.bowl
  # puts you.frames.inspect
  # me.bowl
  # puts me.frames.inspect
# end


class Turn
  def initialize(players)
    @players = players
    @players.each { |player| player.bowl }
    @players.each { |player| puts player.frames.inspect }
    puts
  end
end


class Game
  attr_reader :players # :winner 
  def initialize(num_players)
    @players = []
    num_players.times { @players << Player.new }
  end
  
  def play_game
    10.times { Turn.new(@players) }
  end
end


# puts "bob"
# bob = Player.new
# bob.bowl
# puts bob.frames.inspect
# 9.times { bob.bowl }
# puts bob.frames.inspect

# puts "turns"
# alpha = Player.new
# beta = Player.new
# 10.times do 
  # turn = Turn.new [alpha, beta]
# end

# puts "test game"
# test_game = Game.new(3)
# test_game.play_game



# ===================================================================================================================================================================
# METZ "test everything just once and in the proper place"
# "This choice between injecting real or fake objects has far-reaching consequences.
# Injecting the same objects at test time as are used at runtime ensures that tests break
# correctly but may lead to long running tests. Alternatively, injecting doubles can speed
# tests but leave them vulnerable to constructing a fantasy world where tests work but
# the application fails."

require "test/unit"

class TestRollCalc < Test::Unit::TestCase
  def test_roll_limits
    roll = RollCalc.new
    assert roll.results.max <= 10
    assert roll.results.min >= 0
  end
  
  def test_roll_sum
    roll = RollCalc.new
    assert roll.results.reduce(:+).between? 0, 10
  end
    
  def test_roll_sum_skill
    skill = 15
    roll = RollCalc.new(skill)
    assert roll.results.reduce(:+).between? 0, 10
  end
end


# doubles provide deterministic cases for testing Frame
class StrikeDouble
  def results
    [10]
  end
end

class SpareDouble
  def results
     [2,8]
  end
end

class OpenFrameDouble
  def results
    [3,4]
  end
end


# Frame only knows that its argument responds to results
class TestFrame < Test::Unit::TestCase
  def test_first_roll
    frame = Frame.new OpenFrameDouble.new
    assert frame.first_roll == 3
  end
  
  def test_second_roll
    frame = Frame.new OpenFrameDouble.new
    assert frame.second_roll == 4
  end
      
  def test_frame_total
    frame = Frame.new OpenFrameDouble.new
    assert frame.total == 7
  end
  
  def test_second_roll_nil
    frame = Frame.new StrikeDouble.new
    assert frame.second_roll.nil?
  end
  
  def test_frame_strike
    frame = Frame.new StrikeDouble.new
    assert frame.strike?      
  end 
  
  def test_frame_spare
    frame = Frame.new SpareDouble.new
    assert frame.spare?
  end
end



# for understanding structure of object
def roll_tests_temp
  puts "roll_tests line #{__LINE__}"
  roll1 = Roll.new
  puts "this is object: #{roll1}"
  puts "this is reading result w/in object: #{roll1.result} / no change between readings: #{roll1.result}"
  roll2 = Roll.new.result
  puts "this is result of new object saved to var: #{roll2}"
  puts
end

