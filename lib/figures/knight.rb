require_relative "figures"

class Knight < Figures
  attr_accessor :current_tile, :sprite, :first_move
end


class Knight_white < Knight
   
  def initialize
    @sprite = Sprite.new(
      'img/knight-w.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "white"
  end

end

class Knight_black < Knight

  def initialize
    @sprite = Sprite.new(
      'img/knight-b.svg',
      x: 0, y: 0,
      width: Config.tile_size,
      height: Config.tile_size
    )
    @current_tile = nil
    @first_move = true
    @color = "black"
  end

end