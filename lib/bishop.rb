class Bishop_white 
  def initialize
    @sprite = Sprite.new(
      'img/bishop-w.svg',
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

class Bishop_black
  def initialize
    @sprite = Sprite.new(
      'img/bishop-b.svg',
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