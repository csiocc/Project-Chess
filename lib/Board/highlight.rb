require_relative "../gamelogic/gamestate"
require_relative "../config"

module Highlight
  include Config
  include Game_states
  @highlight_square = nil

  def self.update_highlight
    selected_tile = Game_states.selected_tile #get tile to highlight

    if selected_tile
      unless @highlight_square #create highlight square if none existing
        @highlight_square = Square.new(size: Config.tile_size, color: [1, 1, 0, 0.4])
      end
      @highlight_square.x = selected_tile.draw_cords[:x] #highlight suqare positioning
      @highlight_square.y = selected_tile.draw_cords[:y]
      @highlight_square.add
    elsif @highlight_square
      @highlight_square.remove #if no tile selected remove highlight
    end
    return @highlight_square
  end

end