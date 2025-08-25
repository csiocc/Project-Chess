### tiles on the board ###
class Tile
  attr_accessor :cords, :draw_cords

  def initialize
    @cords = nil
    @draw_cords = { x: 0, y: 0 }
  end
end