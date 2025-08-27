require_relative "figures"
require 'ruby2d'

class Pawn < Figures
  
end

class Pawn_white < Pawn
  attr_accessor :current_tile, :sprite, :first_move, :en_passant

  def initialize
    @sprite = Sprite.new(
      'img/pawn-w.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
    @first_move = true
    @color = "white"
    @en_passant = false
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end

end

class Pawn_black < Pawn
  attr_accessor :current_tile, :sprite, :first_move, :en_passant

  def initialize
    @sprite = Sprite.new(
      'img/pawn-b.svg',
      x: 0, y: 0,
      width: 128,
      height: 128
    )
    @current_tile = nil
    @first_move = true
    @color = "black"
    @en_passant = false
  end

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end

end