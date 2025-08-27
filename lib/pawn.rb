require_relative "figures"
require 'ruby2d'

class Pawn < Figures
  attr_accessor :current_tile, :sprite, :first_move, :en_passant
end

class Pawn_white < Pawn
  
  def initialize
    @sprite = Sprite.new(
      'img/pawn-w.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "white"
    @en_passant = false
  end

end

class Pawn_black < Pawn

  def initialize
    @sprite = Sprite.new(
      'img/pawn-b.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "black"
    @en_passant = false
  end

end