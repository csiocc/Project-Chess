require_relative "figures"

class Knight < Figures
  
end


class Knight_white < Knight
  attr_accessor :current_tile, :sprite, :first_move 
  POSSIBLE_MOVES = [
    [2, 1], [1, 2],
    [-1, 2], [-2, 1],
    [-2, -1], [-1, -2],
    [1, -2], [2, -1]
  ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES

  def initialize
    @sprite = Sprite.new(
      'img/knight-w.svg',
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

class Knight_black < Knight
  attr_accessor :current_tile, :sprite, :first_move
  POSSIBLE_MOVES = [
    [2, 1], [1, 2],
    [-1, 2], [-2, 1],
    [-2, -1], [-1, -2],
    [1, -2], [2, -1]
  ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES

  def initialize
    @sprite = Sprite.new(
      'img/knight-b.svg',
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