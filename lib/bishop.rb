require_relative "figures"

class Bishop < Figures
  
end

class Bishop_white < Bishop
  attr_accessor :current_tile, :sprite, :first_move

  POSSIBLE_MOVES = [
  [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
  [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
  [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
  [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]
].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES

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

  POSSIBLE_MOVES = [
  [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
  [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
  [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
  [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]
  ].freeze

  POSSIBLE_FIRST_MOVES = nil
  POSSIBLE_TAKES = POSSIBLE_MOVES

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