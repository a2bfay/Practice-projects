# BOWLING SIMULATOR WITH SCORING DONE FRAME-BY-FRAME (vs. 'kata' version)

# CLASSES : Player / Frame / PlayerGame / ScoringWindow / Game / TurnRecorder
# ===========================================================================

require "test/unit"

# This class creates arrays of weighted-random rolls (1 or 2, from 10 pins).
#       data: skill
#       behavior: rolls generated according to skill
class Player
  attr_reader :skill 
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
    weighted_roll(@pins_standing) unless (pins_hit == 10 || @roll_no > 2)
  end
  
  def apply_skill(pins)
    picks = []
    (@skill + 1).times { picks << rand(0..pins)
                         break if picks.max == pins }
    picks.max
  end
end


# This class stores and evaluates a single array of rolls.
#       data: rolls
#       behavior: calculates total and checks for bonus
class Frame
  attr_reader :results            
  def initialize(player_roll)
    @results = player_roll        
  end                              
  
  def first_roll
    @results[0]
  end
  
  def second_roll
    @results[1]
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


# This class generates and stores Frame objects, then sends for scoring.
#       data: player, frames, score subtotals
#       behavior: generates new frames, passes to scoring process
class PlayerGame
  attr_reader :player, :frames, :scores
  def initialize(player) 
    @player = player
    @frames = []
    @scores = []
  end
  
  def take_turn
    @frames.length == 9  ?  bowl_tenth  :  bowl
    score_turn
  end

  def frames_played
    @frames.map { |fr| fr.results }
  end
  
  def scores_posted
    @scores.flatten
  end
  
    private
  
  def bowl
    player_frame = Frame.new(@player.roll)  
    @frames << player_frame                  
  end

  def bowl_tenth
    base_frame = Frame.new(@player.roll)
    if base_frame.strike? || base_frame.spare?
      tenth_frame = generate_bonus(base_frame)
      @frames << tenth_frame
    else
      @frames << base_frame
    end
  end
  
  def generate_bonus(base_frame)
      first_bonus  = Frame.new(@player.roll)
      second_bonus = Frame.new(@player.roll)
      source_rolls = [base_frame.results, first_bonus.results, second_bonus.results]
      three_rolls  = source_rolls.flatten.shift(3)
      Frame.new(three_rolls)
  end
    
  def current_frame
    @frames.length
  end
  
  def last_known_score
    @scores.compact.empty?  ?  0  :  @scores.compact[-1]
  end
  
  def score_turn
    active_frames = (current_frame <= 3)  ?  @frames  :  @frames[-3..-1]
    window = ScoringWindow.new(active_frames, last_known_score)
    @scores     <<  window.return_scores[-1]
    @scores[-2] ||= window.return_scores[-2] if window.return_scores.length >= 2
    @scores[-3] ||= window.return_scores[-3] if window.return_scores.length == 3
  end
end


# This class completes open bonuses and scores or defers current frame.
#       data: recent frames and most recent subtotal
#       behavior: generates array of up to three subtotals and/or nil entries
class ScoringWindow
  attr_reader :return_scores
  def initialize(frames, base_score)
    raise RangeError unless base_score >= 0
    @frames = frames
    @base_score = base_score
    @return_scores = []
    calculate_scores
  end

  private
    
  def update_score(amount)
    @base_score += amount
    @return_scores << @base_score
  end
  
  def two_prev
    @frames[-3]
  end
  
  def one_prev
    @frames[-2]
  end
  
  def current
    @frames[-1]
  end
  
  def tenth_bonus?
    current.results.length == 3
  end
    
  def calculate_scores
    update_two_prev
    if tenth_bonus?
      update_ninth_before_bonus
      score_tenth_bonus
    else
      update_one_prev
      score_current
    end  
  end
    
  def update_two_prev
    return if two_prev.nil?
    return unless (two_prev.strike? && one_prev.strike?)
    frame_rolls = @frames.map { |fr| fr.results }    
    flat_rolls = frame_rolls.flatten
    bonus = flat_rolls[1] + flat_rolls[2]
    update_score(10 + bonus)
  end
      
  def update_one_prev
    return if one_prev.nil?
    return unless (one_prev.strike? || one_prev.spare?)
    if (one_prev.strike? && current.strike?)
      @return_scores << nil
    else
      bonus = one_prev.strike?  ?  current.total  :  current.first_roll
      update_score(10 + bonus)
    end  
  end

  def score_current
    if current.strike? || current.spare?
      @return_scores << nil
    else
      update_score(current.total)
    end      
  end
  
  def update_ninth_before_bonus
    return unless (one_prev.strike? || one_prev.spare?)
    bonus = one_prev.strike?  ? (current.first_roll + current.second_roll)  
                              :  current.first_roll
    update_score(10 + bonus)
  end
  
  def score_tenth_bonus
    update_score(current.total)
  end
end


# This class creates a single match and directs player(s) to bowl in sequence.
#       data: set of players, PlayerGames
#       behavior: directs and prints turns, identifies winner
class Game
  attr_reader :players, :player_games # :winner 
  def initialize(players, turn_recorder)
    @players = players
    @turn_recorder = turn_recorder
    @player_games = []
    @players.each { |player| @player_games << PlayerGame.new(player) }
    play_game
  end
  
  private
  
  def play_game
    10.times { play_turn; record_turn }
  end
  
  def play_turn
    @player_games.each { |curr_player| curr_player.take_turn }
  end
  
  def record_turn
    @turn_recorder.record(@player_games)
  end
end


class TurnRecorder
  attr_reader :turns
  def initialize(players)
    @players = players
    @turns = []
  end
  
  def record(player_games)
    game_turn = []
    @players.each_index do |i|
      rec_scores = player_games[i].scores_posted
      rec_frames = player_games[i].frames_played
      player_turn = [rec_scores, rec_frames]
      game_turn << player_turn
    end
    @turns << game_turn
  end
  
  def print_game_state(turn)
    print_players
    format_output(turn)
  end
  
  private
  
  def print_players
    puts
    (0...@players.length).each do |index|
      player = index + 1
      print "P#{player}(#{@players[index].skill})".rjust(7), "___________ "
    end
    puts
  end
  
  # This prints complete game-to-date as of each turn,
  #   modeling output as needed by display at alley.
  def format_output(turn)
    current_turn = @turns[turn]
    (0..turn).each do |fr|
      (0...@players.length).each do |pl|
        score = current_turn[pl][0][fr]
        frame = current_turn[pl][1][fr]
        print "#{score}".rjust(6), " "
        print "#{frame}".ljust(12)
      end
      puts
    end
  end
end



# GAMEPLAY
# ===========================================================================
# Following two methods handle user input and screen output

# Sets players and skill levels.
def input_player_settings
  print "\n\nHow many players(1-4)?  "
    numplayers = gets.chomp.to_i
    numplayers = 1 if numplayers < 1
    numplayers = 4 if numplayers > 4
  
  @input_players = []
  puts "Enter skill level 0-15 (2+ = good, 4+ = v.good, 6+ = pro):"
  (1..numplayers).each do |p|
    print "Skill level for player #{p}?  "
    skill = gets.chomp.to_i
    skill = 0 if skill < 0
    @input_players << Player.new(skill)
  end
end


# Creates new game. 
def single_game
  input_player_settings
  turn_recorder = TurnRecorder.new(@input_players)
  game = Game.new(@input_players, turn_recorder)
  (0..9).each { |i| turn_recorder.print_game_state(i) }
  puts
end

single_game



# TESTS
# ===========================================================================
class TestPlayer < Test::Unit::TestCase
  def test_roll_limits
    player = Player.new
    assert player.roll.max <= 10
    assert player.roll.min >= 0
  end
  
  def test_roll_sum
    player = Player.new
    assert player.roll.reduce(:+).between? 0, 10
  end
    
  def test_roll_sum_skill
    player = Player.new 15
    assert player.roll.reduce(:+).between? 0, 10
  end
end


# Frame only knows that the object passed to it responds to :results.
class TestFrame < Test::Unit::TestCase
  def test_first_roll
    frame = Frame.new [3,4]
    assert frame.first_roll == 3
  end
  
  def test_second_roll
    frame = Frame.new [3,4]
    assert frame.second_roll == 4
  end
      
  def test_frame_total
    frame = Frame.new [3,4]
    assert frame.total == 7
  end
  
  def test_second_roll_nil
    frame = Frame.new [10]
    assert frame.second_roll.nil?
  end
  
  def test_frame_strike
    frame = Frame.new [10]
    assert frame.strike?      
  end 
  
  def test_frame_spare
    frame = Frame.new [2,8]
    assert frame.spare?
  end
end


# Seems tough to test - game logic is here, with non-deterministic results,
#   and requires contact with all classes except Game.
# Since overall program is small, creating actual objects instead of mocks.
class TestPlayerGame < Test::Unit::TestCase
  def test_take_turn_appends_to_frames_array
    playergame = PlayerGame.new(Player.new)
    playergame.take_turn
    assert playergame.frames.length == 1
  end
  
  def test_take_turn_appends_to_scores_array
    playergame = PlayerGame.new(Player.new)
    playergame.take_turn
    assert playergame.scores.length == 1
  end
    
  def test_frames_played_extracts_numeric_values_only
     playergame = PlayerGame.new(Player.new)
     playergame.take_turn
     assert playergame.respond_to?(:max) == false
     assert playergame.frames_played.respond_to?(:max) == true
  end
end


class TestScoringWindow < Test::Unit::TestCase
  def setup
    @open_frame = Frame.new([3, 4])
    @strike = Frame.new([10])
    @spare = Frame.new([2,8])
    @bonus_tenth = Frame.new([8, 2, 10])
    @perfect_tenth = Frame.new([10, 10, 10])
  end
  
  def test_open_frames_return_newest_only
    window = ScoringWindow.new([@open_frame, @open_frame, @open_frame], 14)
    assert window.return_scores == [21]
  end
  
  def test_spare_frames_return_one_update_plus_nil
    window = ScoringWindow.new([@spare, @spare, @spare], 12)
    assert window.return_scores.length == 2
    assert window.return_scores == [24, nil]
  end
  
  def test_strike_frames_return_one_update_plus_two_nils
    window = ScoringWindow.new([@strike, @strike, @strike], 0)
    assert window.return_scores == [30, nil, nil]
  end
  
  def test_strikes_then_open_return_two_updates_plus_newest
    window = ScoringWindow.new([@strike, @strike, @open_frame], 0)
    assert window.return_scores == [23, 40, 47]
  end
    
  def test_bonus_tenth_scored_correctly
    window = ScoringWindow.new([@strike, @strike, @bonus_tenth], 0)
    assert window.return_scores == [28, 48, 68]
  end
  
  def test_perfect_game_ends_correctly
    window = ScoringWindow.new([@strike, @strike, @perfect_tenth], 210)
    assert window.return_scores == [240, 270, 300]
  end
end


# GameTurn uses only one interface (take_turn), but it's a command;
#   the data in each Player changes when it gets that message.
# As above, testing w/ actual objects vs. mocks b/c overall program is small.
class TestGame < Test::Unit::TestCase
  def setup
    @singleplayer = [Player.new]
    @multiplayer = [Player.new, Player.new, Player.new, Player.new]
    @turn_rec_single = TurnRecorder.new(@singleplayer)
    @turn_rec_mult = TurnRecorder.new(@multiplayer)
  end

  def test_single_game_generates_ten_frames
    game = Game.new(@singleplayer, @turn_rec_single)
    assert game.player_games.length == 1
    assert game.player_games[0].frames_played.length == 10    
  end
  
  def test_single_game_generates_valid_score
    game = Game.new(@singleplayer, @turn_rec_single)
    total = game.player_games[0].scores[-1]
    assert total.between? 0, 300    
  end
  
  def test_multplr_game
    mpl_game = Game.new(@multiplayer, @turn_rec_mult)
    assert mpl_game.player_games.length == 4
    assert mpl_game.player_games[3].frames_played.length == 10 
  end  
end