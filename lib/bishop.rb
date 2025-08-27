require_relative "figures"

class Bishop < Figures
  
end

class Bishop_white < Bishop
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/bishop-w.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
    @first_move = true
    @color = "white"
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end

end

class Bishop_black < Bishop
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/bishop-b.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
    @first_move = true
    @color = "black"
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end
end