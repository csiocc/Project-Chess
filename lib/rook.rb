require_relative "figures"

class Rook_white < Figures
  attr_accessor :current_tile, :sprite, :first_move

  POSSIBLE_MOVES = [
    [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
    [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
    [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0],
    [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]
    ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES

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

class Rook_black < Figures
  attr_accessor :current_tile, :sprite, :first_move

  POSSIBLE_MOVES = [
    [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
    [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
    [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0],
    [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]
    ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES
  
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