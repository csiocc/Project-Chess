#class for all figures for shared functions

class Figures 
  def legal_move?(cords)
    current_cords = @current_tile.cords
    dx = (current_cords[0] - cords[0]).abs
    dy = (current_cords[1] - cords[1]).abs
    move = [dx, dy].sort
    POSSIBLE_MOVES.include?(move)
  end
end