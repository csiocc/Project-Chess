require_relative "figures"
require 'ruby2d'

class Pawn_white < Figures

  POSSIBLE_MOVES = [
    [1, 0]
  ].freeze

  POSSIBLE_FIRST_MOVES = [
    [2, 0]
  ].freeze

  POSSIBLE_TAKES = [
    [1, 1], [1, -1]
  ].freeze

  POSSIBLE_FIRST_TAKES = [
    [2, 1], [2, -1]
  ].freeze


  def initialize
    @sprite = Sprite.new(
      'img/pawn-w.svg',
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

class Pawn_black

  POSSIBLE_MOVES = [
    [-1, 0]
  ].freeze

  POSSIBLE_FIRST_MOVES = [
    [-2, 0]
  ].freeze

  POSSIBLE_TAKES = [
    [-1, 1], [-1, -1]
  ].freeze

  POSSIBLE_FIRST_TAKES = [
    [-2, 1], [-2, -1]
  ].freeze

  def initialize
    @sprite = Sprite.new(
      'img/pawn-b.svg',
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