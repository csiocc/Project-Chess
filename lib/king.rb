require_relative "figures"

class King < Figures
  attr_accessor :current_tile, :sprite, :first_move

end

class King_white < King
  
  def initialize
    @sprite = Sprite.new(
      'img/king-w.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "white"
  end



end

class King_black < King
  
  def initialize
    @sprite = Sprite.new(
      'img/king-b.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "black"
  end

end