require_relative "figures"

class King_white < Figures
  attr_accessor :current_tile, :sprite, :first_move
  
  POSSIBLE_MOVES = [
    [1, 0], [-1, 0], [0, 1], [0, -1],
    [1, 1], [1, -1], [-1, 1], [-1, -1]
  ].freeze

  POSSIBLE_FIRST_MOVES = [
    [2, 0],  # rochade (right, kingside)
    [-2, 0]  # rochade (left, queenside)
  ].freeze

  def initialize
    @sprite = Sprite.new(
      'img/king-w.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
    @first_move = true
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end

end

class King_black < Figures
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
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end
end