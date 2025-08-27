require_relative "figures"

class Queen < Figures
  
end
class Queen_white < Queen
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/queen-w.svg',
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

class Queen_black < Queen
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/queen-b.svg',
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