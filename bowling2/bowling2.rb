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
# the basic units here might be: player, frame, player-game (which combines frames by player), eventually game itself (given mult players)

class Player
  attr_reader :skill
  def initialize(skill = 0)
    @skill = skill
  end  
end

class PlayerSimple
  def initialize; end
end

class Frame
  def initialize; end
end

class Roll
  def initialize(pins_standing = 10)
    @pins_standing = pins_standing    
  end
  
  def hit_pins
    @pins_hit = rand(0..@pins_standing)
    #@pins_standing -= @pins_hit
  end
  # Roll.hit_pins  # okay, there's something I definitely don't get so far...
  # is it about having roll try to set things up and store a result at the same time?
  def result
    puts @pins_hit
  end
end


player1 = Player.new(3)
# puts player1.skill
player2 = PlayerSimple.new

roll1 = Roll.new
roll1.result
roll1.result
# puts roll1
# puts roll1
# pins_remaining = 10 - roll1
# puts pins_remaining
# roll2 = Roll.new(pins_remaining)
# puts roll2