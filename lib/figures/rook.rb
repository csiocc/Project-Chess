require_relative "figures"

class Rook < Figures
  attr_accessor :current_tile, :sprite, :first_move
end

class Rook_white < Rook
  
  def initialize
    @sprite = Sprite.new(
      'img/rook-w.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "white"
  end

end

class Rook_black < Rook

  def initialize
    @sprite = Sprite.new(
      'img/rook-b.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "black"
  end

end