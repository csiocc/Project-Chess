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
@saves_displayed = false

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

  if @game_state == :select_save_to_load && !@saves_displayed
    save_files = SaveGame.get_save_files
    p "save files: #{save_files}" if DEBUG
    test.display_saves(save_files)
    @saves_displayed = true
  end

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
  clickd_tile = test.find_tile({ x: event.x, y: event.y })
  p "clicked tile is #{clickd_tile}" if DEBUG && clickd_tile
  p "current figure is #{clickd_tile.figure}" if DEBUG && clickd_tile
  clicked_button = test.find_button({ x: event.x, y: event.y }) 
  p "Gamestate: #{@game_state}" if DEBUG
  # Enter menu if a button is clicked, but not when already in the load menu
  if clicked_button && @game_state != :select_save_to_load
    p "entering menu" if DEBUG
    @last_game_state = @game_state if @game_state != :menu
    @game_state = :menu
  end
  
  current_game_state = @game_state.is_a?(Hash) ? @game_state[:status] : @game_state

  case current_game_state
    when :white_turn
      result = Game_states.select_figure_white(clickd_tile, test)
      @game_state = result[:status] if result
    when :select_target_tile_white
      result = Game_states.select_target_tile_white(clickd_tile, test)
      @game_state = result[:status]
    when :black_turn
      result = Game_states.select_figure_black(clickd_tile, test)
      @game_state = result[:status] if result
    when :select_target_tile_black
      result = Game_states.select_target_tile_black(clickd_tile, test)
      @game_state = result[:status]
    when :promote_pawn
      @game_state = Game_states.handle_promotion(clickd_tile, test)
    when :check_white
      result = Game_states.check_status("white", test)
      valid_figures = result[:legal_moves].map { |move| move[:figure] }
      new_result = Game_states.select_figure_white(clickd_tile, test, valid_figures)
      @game_state = new_result[:status] if new_result
    when :check_black
      result = Game_states.check_status("black", test)
      valid_figures = result[:legal_moves].map { |move| move[:figure] }
      new_result = Game_states.select_figure_black(clickd_tile, test, valid_figures)
      @game_state = new_result[:status] if new_result
    when :check_mate_black
      puts "White wins!"
    when :check_mate_white
      puts "Black wins!"
    when :menu
      if clicked_button
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
          close
        when "Save"
          test.save_game_state = @last_game_state ? @last_game_state : @game_state
          SaveGame.save("Save", test.to_json)
        when "Load"
          @game_state = :select_save_to_load
          @saves_displayed = false
        end
      else
        # If clicked outside buttons in menu, return to last game state
        @game_state = @last_game_state if @last_game_state
        @last_game_state = nil
      end
    when :select_save_to_load
      if clicked_button
        if clicked_button.text == "Back"
          test.reset_button_texts
        elsif clicked_button.text           
          @game_state = :menu
          loaded_data = SaveGame.load(clicked_button.text)
          p "clicked button text: #{clicked_button.text}" if DEBUG
          if loaded_data
            p "loaded data: #{loaded_data}" if DEBUG
            test = loaded_data[0]
            loaded_state = test.save_game_state
            loaded_state = loaded_state[:status] if loaded_state.is_a?(Hash)
            loaded_state = loaded_state.to_sym rescue nil if loaded_state.is_a?(String)
            loaded_state = :white_turn unless [:white_turn, :black_turn, :promote_pawn, :menu,
                                           :select_target_tile_white, :select_target_tile_black,
                                           :check_white, :check_black].include?(loaded_state)
            @game_state = :menu                               
            @game_state = loaded_state
            test.save_game_state = nil
          end
          p "reseting button texts" if DEBUG
          test.reset_button_texts
        end
        @saves_displayed = false
      end
  end

  @highlight_square = Highlight.update_highlight
end


 # show window #
show
