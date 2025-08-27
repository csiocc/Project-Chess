require_relative "figures"

class King < Figures
  
end

class King_white < King
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/king-w.svg',
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

class King_black < King
  attr_accessor :current_tile, :sprite, :first_move
  
  def initialize
    @sprite = Sprite.new(
      'img/king-b.svg',
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