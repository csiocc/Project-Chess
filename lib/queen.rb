class Queen_white < Figures
  attr_accessor :current_tile
  def initialize
    @sprite = Sprite.new(
      'img/queen-w.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end

end

class Queen_black < Figures
  attr_accessor :current_tile
  def initialize
    @sprite = Sprite.new(
      'img/queen-b.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end
end