require_relative "figures"
require 'ruby2d'

class Pawn_white < Figures
  attr_accessor :current_tile, :sprite, :first_move

  POSSIBLE_MOVES = [
    [1, 0]
  ].freeze

  POSSIBLE_FIRST_MOVES = [
    [1, 0], [2, 0]
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

  def first_move?
    @first_move
  end

end

class Pawn_black < Figures
  attr_accessor :current_tile

  POSSIBLE_MOVES = [
    [-1, 0]
  ].freeze

  POSSIBLE_FIRST_MOVES = [
    [-1, 0], [-2, 0]
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

  def first_move?
    @first_move
  end

end