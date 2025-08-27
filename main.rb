require_relative "lib/board"
require_relative "lib/gamestate_module"
require_relative "lib/valid_moves_module"
require "ruby2d"
DEBUG = false

system 'clear'

set title: 'Chess press ESC to exit'
set width: 1280
set height: 1024

include Valid_moves
include Game_states
test = Board.new
test.setup
test.draw_board
test.setup_figures
Valid_moves.build_targets


@game_state = :white_turn
@highlight_square = nil #highlight square to highlight selected figure



on :key_down do |event|
  case event.key
  when 'escape'
    close
  when "r"
    test = nil
    test = Board.new
    test.setup
    test.draw_board
    test.setup_figures
    @game_state = :white_turn
  end
end

def update_highlight
  selected_tile = Game_states.selected_tile #get tile to highlight

  if selected_tile
    unless @highlight_square #create highlight square if none existing
      @highlight_square = Square.new(size: 128, color: [1, 1, 0, 0.4])
    end
    @highlight_square.x = selected_tile.draw_cords[:x] #highlight suqare positioning
    @highlight_square.y = selected_tile.draw_cords[:y]
    @highlight_square.add
  elsif @highlight_square
    @highlight_square.remove #if no tile selected remove highlight
  end
end

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
  end
  update_highlight
  
end

show
