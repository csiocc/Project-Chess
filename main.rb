require_relative "lib/board"
require_relative "lib/gamestate_module"
require "ruby2d"
DEBUG = false

system 'clear'

set title: 'Chess press ESC to exit'
set width: 1024
set height: 1024

test = Board.new
test.setup
test.draw_board
test.setup_figures
include Game_states
@game_state = :white_turn



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
    when :black_turn
      @game_state = Game_states.select_figure_black(clickd_tile, test)
      p "game state: #{@game_state}" if DEBUG
    when :select_target_tile_black
      @game_state = Game_states.select_target_tile_black(clickd_tile, test)
      p "game state: #{@game_state}" if DEBUG
  end
  
end

show
