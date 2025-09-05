require_relative "lib/board"
require_relative "lib/gamestate"
require_relative "lib/valid_moves"
require_relative "lib/config"
require_relative "lib/tile"
require_relative "lib/highlight"
require_relative "lib/check"
require_relative "lib/save"
require_relative "lib/ai"
require_relative "lib/ai_runner"
# display gem #
require "ruby2d"
### modules ###
include Config
include Valid_moves
include Game_states
include Highlight
include Check 
# debug option #
DEBUG = false
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
  end
end

#update loop#
update do
  if (@game_state == :select_save_to_load || @game_state == :select_save_to_del) && !@saves_displayed
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
  @game_state = AiRunner.tick!(test, @game_state)
end

# mouse events #
on :mouse_down do |event|
  clickd_tile = test.find_tile({ x: event.x, y: event.y })
  p "clicked tile is #{clickd_tile}" if DEBUG2 && clickd_tile
  p "current figure is #{clickd_tile.figure}" if DEBUG && clickd_tile
  clicked_button = test.find_button({ x: event.x, y: event.y }) 

  if AiRunner.ai_controls_turn?(@game_state) && !clicked_button
    next
  end

  p "Gamestate: #{@game_state}" if DEBUG
  # Enter menu if a button is clicked, but not when already in the load menu
  if clicked_button && ![:select_save_to_load, :select_save_to_del].include?(@game_state)
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
    when :stale_mate
      puts "Stalemate!"
    when :menu
      if clicked_button
        case clicked_button.text
        when "Reset"
          puts "Reset"
          test = Board.new
          AiRunner.reset!
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
        when /^AI White: (ON|OFF)$/
          current_on = Regexp.last_match(1) == "ON"
          new_on = !current_on
          AiRunner.set_ai_for(:white, new_on)
          clicked_button.update_text("AI White: #{new_on ? 'ON' : 'OFF'}")
        when /^AI Black: (ON|OFF)$/
          current_on = Regexp.last_match(1) == "ON"
          new_on = !current_on
          AiRunner.set_ai_for(:black, new_on)
          clicked_button.update_text("AI Black: #{new_on ? 'ON' : 'OFF'}")
        end
      else
        # If clicked outside buttons in menu, return to last game state
        @game_state = @last_game_state if @last_game_state
        @last_game_state = nil
      end
    when :select_save_to_load
      if clicked_button
        result = Game_states.select_save_to_load(clicked_button, test) 
        @game_state = result if !result.nil?
        @saves_displayed = false
      end
    when :select_save_to_del
      result = Game_states.select_save_to_del(clicked_button, test)
      @game_state = result if !result.nil?
      @saves_displayed = false
  end

  @highlight_square = Highlight.update_highlight
end


 # show window #
show
