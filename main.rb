require_relative "lib/board"
require_relative "lib/gamestate"
require_relative "lib/valid_moves"
require_relative "lib/config"
require_relative "lib/tile"
require_relative "lib/highlight"
require_relative "lib/check" ####### ONLY FOR TEST####
require_relative "lib/save"
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
DEBUG2 = false
system 'clear'

# setup display window #
set title: 'Chess press ESC to exit'
set width: Config.window_width
set height: Config.window_size

# setup playboard #
test = Board.new

Valid_moves.build_targets


# game state variables #
@game_state = :menu
@highlight_square = nil #highlight square to highlight selected figure
@last_game_state = nil

# key events #
on :key_down do |event|
  case event.key
  when 'escape'
    close
  when "r"
    test = nil
    test = Board.new
    test.setup_figures
    @game_state = :menu
  end
end

update do
  next unless @game_state == :white_turn || @game_state == :black_turn || @game_state == :promote_pawn

  case @game_state
  when :white_turn
    if @last_displayed_turn != :white
      puts "White Turn"
      @last_displayed_turn = :white
    end
  when :black_turn
    if @last_displayed_turn != :black
      puts "Black Turn"
      @last_displayed_turn = :black
    end
  end
end

# mouse events #
on :mouse_down do |event|
  save_value = test.to_json
  clickd_tile = test.find_tile({ x: event.x, y: event.y })
  clicked_button = test.find_button({ x: event.x, y: event.y }) 
  if test.white_storage.include?(clickd_tile) || test.black_storage.include?(clickd_tile) || test.buttons.include?(clicked_button)
    p "entering menu" if DEBUG
    @last_game_state = @game_state if @last_game_state.nil?
    @game_state = :menu
  end
  
  case @game_state.is_a?(Hash) ? @game_state[:status] : @game_state
    when :white_turn
      result = Game_states.select_figure_white(clickd_tile, test)
      p "result is : #{result}" if DEBUG
      @game_state = result[:status]  if result
      @game_state = :menu if result.nil?
      p "game state: #{@game_state}" if DEBUG
    when :select_target_tile_white
      result = Game_states.select_target_tile_white(clickd_tile, test)
      puts "result is : #{result}" if DEBUG2
      @game_state = result[:status]
      p "game state: #{@game_state}" if DEBUG
      Game_states.reset_en_passant_black(test)
    when :black_turn
      result = Game_states.select_figure_black(clickd_tile, test)
      @game_state = result[:status]  if result
      @game_state = :menu if result.nil?
      p "game state: #{@game_state}" if DEBUG
    when :select_target_tile_black
      result = Game_states.select_target_tile_black(clickd_tile, test)
      @game_state = result[:status]
      p "game state: #{@game_state}" if DEBUG
      Game_states.reset_en_passant_white(test)
    when :promote_pawn
      @game_state = Game_states.handle_promotion(clickd_tile, test)
    when :check_white
      result = Game_states.check_status("white", test)
      valid_figures = result[:legal_moves].map { |move| move[:figure] }
      new_result = Game_states.select_figure_white(clickd_tile, test, valid_figures)
      @game_state = new_result[:status] if new_result
      p "#{result[:legal_moves].length} legal moves found"
      puts result[:legal_moves]
    when :check_black
      result = Game_states.check_status("black", test)
      valid_figures = result[:legal_moves].map { |move| move[:figure] }
      new_result = Game_states.select_figure_black(clickd_tile, test, valid_figures)
      @game_state = new_result[:status] if new_result
      p "#{result[:legal_moves].length} legal moves found"
      p result[:legal_moves]
    when :check_mate_black
      p "white wins!"
    when :check_mate_white
      p "black wins!"
    when :menu
      p "clicked button is #{clicked_button} text is #{clicked_button&.text}" if DEBUG
      if clicked_button
        p "clicked button is #{clicked_button} text is #{clicked_button.text}" if DEBUG
        p "array" if clicked_button.is_a?(Array)
        next if clicked_button.is_a?(Array)

        case clicked_button.text
        when "Reset"
          puts "Reset"
          test = Board.new
          @game_state = :menu
        when "Start"
          puts "Start"
          test.setup_figures
          @game_state = :white_turn
        when "Exit"
          p "Exiting"
          close
        when "Save"
          p "Save"
          SaveGame.save("Save", test.to_json)
        when "Load"
          p "Load"
          loaded = SaveGame.load("Save")
          test = loaded
        end
      
      end
      @game_state = @last_game_state if @game_state == :menu
      @last_game_state = nil
  end

  
  @highlight_square = Highlight.update_highlight
  
end


 # show window #
show
