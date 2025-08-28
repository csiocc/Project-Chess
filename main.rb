require_relative "lib/board"
require_relative "lib/gamestate"
require_relative "lib/valid_moves"
require_relative "lib/config"
require_relative "lib/tile"
require_relative "lib/highlight"
require_relative "lib/check" ####### ONLY FOR TEST####
# display gem #
require "ruby2d"
### modules ###
include Config
include Valid_moves
include Game_states
include Highlight
include Check  ####### ONLY FOR TEST####
# debug option #
DEBUG = true
system 'clear'

# setup display window #
set title: 'Chess press ESC to exit'
set width: Config.window_width
set height: Config.window_size

# setup playboard #
test = Board.new
test.setup_figures
Valid_moves.build_targets


# game state variables #
@game_state = :white_turn
@highlight_square = nil #highlight square to highlight selected figure

# key events #
on :key_down do |event|
  case event.key
  when 'escape'
    close
  when "r"
    test = nil
    test = Board.new
    test.setup_figures
    @game_state = :white_turn
  end
end
# mouse events #
on :mouse_down do |event|
  clickd_tile = test.find_tile({ x: event.x, y: event.y })
  next if clickd_tile.nil? #next if clicked outside of the board
  
  case @game_state
    when :white_turn
      @game_state = Game_states.select_figure_white(clickd_tile, test)
      p "game state: #{@game_state}" if DEBUG
    when :select_target_tile_white
      @game_state = Game_states.select_target_tile_white(clickd_tile, test)
      p "game state: #{@game_state}" if DEBUG
      Game_states.reset_en_passant_black(test)
    when :black_turn
      @game_state = Game_states.select_figure_black(clickd_tile, test)
      p "game state: #{@game_state}" if DEBUG
    when :select_target_tile_black
      @game_state = Game_states.select_target_tile_black(clickd_tile, test)
      p "game state: #{@game_state}" if DEBUG
      Game_states.reset_en_passant_white(test)
    when :check_white
      p "gamestate check white"
    when :check_black
      p "gamestate check black"
  end
  @highlight_square = Highlight.update_highlight
  
end


 # show window #
show
