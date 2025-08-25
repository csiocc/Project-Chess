require_relative "lib/board"
require_relative "lib/tile"
require "ruby2d"
system 'clear'

test = Board.new
test.setup
test.draw_board

set title: 'Chess press ESC to exit'
set width: 1024
set height: 1024

test.setup_figures

#Gamestate management
@selected_tile = nil
@game_state = :select_figure

on :key_down do |event|
  case event.key
  when 'escape'
    close
  end
end

on :mouse_down do |event|
  clickd_tile = test.find_tile({ x: event.x, y: event.y })
  next if clickd_tile.nil? #next if clicked outside of the board
  
  case @game_state
  when :select_figure #select figure
    unless clickd_tile.empty?
      @selected_tile = clickd_tile
      @game_state = :select_target_tile #set game state to select target tile
    else
      p "Leeres Feld angeklickt. Wähle deine Figur!"
    end
  when :select_target_tile #select target tile
    figure = @selected_tile.figure
    if figure.move_legal?(clickd_tile.cords, figure.class, figure)
      if figure.move_line_clear?(clickd_tile.cords, test)
        figure.move(clickd_tile)
        @selected_tile = nil
        @game_state = :select_figure
      end
    else
      p "Bitte wähle einen legalen Move!"
    end
  end
end

show