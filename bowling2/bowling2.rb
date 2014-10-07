# METZ:
# "The knowledge that rims are at [0] should not be duplicated; it should be known in just one place."
# "these few lines of code are a minor inconvenience compared to the permanent cost of repeatedly indexing into a complex array"
# "If you rephrase every one of [a class's] methods as a question, asking the question ought to make sense."

# BOWLING SIMULATOR WITH SCORING DONE FRAME-BY-FRAME (vs. 'kata' version)
# second attempt - trying to design by proper classes/object-orientation
# will write as single-player, then add back multiplayer/skill weights
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


puts; puts


# ---------------------------------------------------------
# returns random selection from seed number
class Roll
  attr_reader :result  

  def initialize(skill = 0, pins_standing = 10)  #add player skill here later?
    raise RangeError unless skill >= 0
    @skill = skill
    @pins_standing = pins_standing   
    @result = weighted_roll
  end
  
  private
  def weighted_roll
    picks = []
    (@skill + 1).times do 
      pins = rand(0..@pins_standing)
      picks << pins
      break if pins == @pins_standing
    end
    picks.max
  end
end


# ---------------------------------------------------------
# stores a set of rolls in an array
# METZ: "Gear no longer cares about the class of the injected object, it merely expects that it implement diameter."
# problem here that calling for new objects explicitly --> how to 'inject' while preserving unless case?
# i.e. if Frame doesn't know how many rolls should 
class Frame
  attr_accessor :results
 
  def initialize(skill)
    first_roll = Roll.new(skill).result
    @results = [first_roll]
    remaining = 10 - first_roll
    @results << Roll.new(skill, remaining).result unless first_roll == 10
  end
  
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


class Player
  attr_reader :skill, :frames
  
  def initialize(skill = 0)
    @skill = skill
    @frames = []
    @scores = []
  end
  
  def bowl
    player_frame = Frame.new(@skill).results
    @frames << player_frame
  end
end


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


puts "bob"
bob = Player.new
bob.bowl
puts bob.frames.inspect
9.times { bob.bowl }
puts bob.frames.inspect

puts "turns"
alpha = Player.new
beta = Player.new
10.times do 
  turn = Turn.new [alpha, beta]
end

puts "test game"
test_game = Game.new(3)
test_game.play_game



# ===================================================================================================================================================================
# METZ "test everything just once and in the proper place"
require "test/unit"
class TestRoll < Test::Unit::TestCase

  def test_roll
    roll = Roll.new
    assert ( roll.result >= 0 && roll.result <= 10 )
  end
  
  def test_roll_skill
    skill = rand(1..15)
    roll = Roll.new(skill)
    assert ( roll.result >= 0 && roll.result <= 10 )
  end
  
  def test_roll_valid_skill
    skill = -2
    assert_raise (RangeError) { roll = Roll.new(skill) }
  end
end


class TestFrame < Test::Unit::TestCase
  
  def test_frame
    frame = Frame.new(0)
    assert frame.results.is_a? Array
    assert frame.results.length >= 1 && frame.results.length <= 2
    assert frame.total >= 0 && frame.total <= 10
  end
  
  def test_frame_skill
    skill = rand(1..15)
    frame = Frame.new(skill)
    assert frame.results.is_a? Array
    assert frame.results.length >= 1 && frame.results.length <= 2
    assert frame.total >= 0 && frame.total <= 10
  end
  
  def test_frame_strike
    frame = Frame.new(0)
    frame.results = [10]    # this requires accessor inside class, which seems like a problem
    assert frame.strike?      # or else is this the wrong place to have that method?
  end
  
  def test_frame_spare
    frame = Frame.new(0)
    frame.results = [2, 8]    # this requires accessor inside class, which seems like a problem
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

