require_relative "figures"

class Queen < Figures
  
end
class Queen_white < Queen
  attr_accessor :current_tile, :sprite, :first_move

  POSSIBLE_MOVES = [
  # straight
  [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
  [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
  [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0],
  [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7],

  # diagonal
  [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
  [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
  [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
  [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]
  ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES

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

  POSSIBLE_MOVES = [
  # straight
  [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
  [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
  [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0],
  [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7],

  # diagonal
  [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
  [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
  [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
  [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]
  ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES
  
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