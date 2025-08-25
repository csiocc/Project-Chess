class Rook_white 

  POSSIBLE_MOVES = [
    [1, 0], [-1, 0],
    [0, 1], [0, -1]
  ].freeze

  def initialize
    @sprite = Sprite.new(
      'img/rook-w.svg',
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

class Rook_black
  def initialize
    @sprite = Sprite.new(
      'img/rook-b.svg',
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