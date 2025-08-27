require_relative "figures"

class Bishop < Figures
  attr_accessor :current_tile, :sprite, :first_move

end

class Bishop_white < Bishop
  
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

end

class Bishop_black < Bishop

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

end