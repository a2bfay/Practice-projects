# METZ:
#
# "It depends upon the array’s structure. If that structure changes, then this 
# code must change. When you have data in an array it’s not long before you 
# have references to the array’s structure all over. The references are leaky. 
# They escape encapsulation and insinuate themselves throughout the code. They
# are not DRY. The knowledge that rims are at [0] should not be duplicated; 
# it should be known in just one place."
#
#   (wheel.rim + wheel.tire instead of wheel[0] + wheel[1])
# "these few lines of code are a minor inconvenience compared
# to the permanent cost of repeatedly indexing into a complex array"
#
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

puts; puts


class Player
  attr_reader :player_num, :skill
  @@players = 0
  def initialize(skill = 0)
    @skill = skill
    @@players += 1
    @player_num = @@players
  end  
end


# ---------------------------------------------------------
# returns random selection from seed number
class Roll
  attr_reader :result  

  def initialize(pins_standing = 10)  #add player skill here later?
    @pins_standing = pins_standing    
    @result = rand(0..pins_standing)
    # will want option for player skill here
  end

  # def weighted_roll
  # end
  
  def strike?
    result == 10
  end
end


def roll_tests_temp
  puts "roll_tests line #{__LINE__}"
  roll1 = Roll.new
  puts "this is object: #{roll1}"
  puts "this is reading result w/in object: #{roll1.result} / no change between readings: #{roll1.result}"
  roll2 = Roll.new.result
  puts "this is result of new object saved to var: #{roll2}"
  puts
end
# roll_tests_temp


# ---------------------------------------------------------
# enacts set of rolls? or is that not object behavior?
#   what QUESTIONS to ask? 1) what are the rolls for this turn?
#   think that's it -- always completes (10th aside), so likely no need to check; on multiplayer level instead?
class PlayerTurn
  attr_reader :rolls
 
  def initialize
    first_roll = Roll.new.result
    @rolls = [first_roll]
    remaining = 10 - first_roll
    @rolls << Roll.new(remaining).result unless first_roll == 10
  end
end


# ---------------------------------------------------------
# stores a set of rolls in an array
class Frame
  attr_reader :frame
  
  def initialize(rolls)
    @frame = rolls.compact
  end
  
  def total
    @frame.reduce(:+)
  end

  def strike?
    @frame[0] == 10
  end
  
  def spare?
    strike? == false && total == 10
  end
end
# 10th frame with [10, 0, 10] and [10, 0, 0] are good test cases...


class FrameTen < Frame  # a full, unique frame might not be best way to handle this...save for now
    
  def spare?  # good for testing override; but would this ever be necessary?
    strike? == false && (@frame[0] + @frame[1]) == 10
  end
end


def frame_tests_temp
  # frame_nil = Frame.new  # doesn't work; treat as error w/in class?
  # puts frame_nil.frame.inspect  # valid - may need to be changed
  # puts
  
  frame0 = Frame.new [3, 6]
  puts frame0.inspect, frame0.frame.inspect
  puts frame0.total
  puts "spare / #{frame0.spare?}"
  puts "strike / #{frame0.strike?}"
  puts

  frame1 = Frame.new [9, 1]
  puts frame1.inspect, frame1.frame.inspect
  puts frame1.total
  puts "spare / #{frame1.spare?}"
  puts "strike / #{frame1.strike?}"
  puts

  frame2 = Frame.new [10]
  puts frame2.inspect, frame2.frame.inspect
  puts frame2.total
  puts "spare / #{frame2.spare?}"
  puts "strike / #{frame2.strike?}"
  puts

  frame3 = Frame.new [2, 8, 10]
  puts frame3.inspect, frame3.frame.inspect
  puts frame3.total
  puts "spare / #{frame3.spare?}"
  puts "strike / #{frame3.strike?}"
  puts

  frame10 = FrameTen.new [2, 8, 10]
  puts frame10.inspect, frame10.frame.inspect
  puts frame10.total
  puts "spare / #{frame10.spare?}"
  puts "strike / #{frame10.strike?}"
  puts
end
# frame_tests_temp   # hard coded - no interaction with other classes


# =============================================================================
def frame_from_turn_tests_temp
  puts "frame_from_turn_tests line #{__LINE__}"
  turn_test = PlayerTurn.new
  puts "#{turn_test} : this is object", turn_test.inspect
  puts turn_test.rolls.inspect

  frame_from_turn = Frame.new(turn_test.rolls)
  puts frame_from_turn.frame.inspect
end
frame_from_turn_tests_temp


# okay, so : are we thinking about a multiplayer game made up of turns (each with several players)
#   or a multiplayer game made up of individual games played in parallel?
# or for one player....
# some class variables as counters useful here?
class Game

end