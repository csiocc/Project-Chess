### tiles on the board ###
class Tile
  attr_accessor :cords, :draw_cords, :figure, :en_passant_clone



  def initialize
    @cords = nil
    @draw_cords = { x: 0, y: 0 }
    @figure = nil
    @en_passant_clone = false
  end

  def setup_figure(figure) 
    @figure = figure
  end

  def empty?
    @figure == nil
  end
end