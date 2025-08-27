require_relative "figures"

class Rook < Figures
  
end

class Rook_white < Rook
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/rook-w.svg',
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

class Rook_black < Rook
  attr_accessor :current_tile, :sprite, :first_move

  def initialize
    @sprite = Sprite.new(
      'img/rook-b.svg',
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