require_relative "figures"

class Queen < Figures
  attr_accessor :current_tile, :sprite, :first_move
end
class Queen_white < Queen

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

end

class Queen_black < Queen

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

end