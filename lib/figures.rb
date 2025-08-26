#class for all figures for shared functions
DEBUG = false

class Figures
  attr_reader :color
  def move_legal?(cords, figure_class, figure)
    current_cords = @current_tile.cords
    dx = (cords[0] - current_cords[0])
    dy = (cords[1] - current_cords[1])
    move = [dx, dy]
    p "move = #{move}" if DEBUG

    if figure.first_move? && !figure_class::POSSIBLE_FIRST_MOVES.nil?
      if figure_class::POSSIBLE_FIRST_MOVES.include?(move)
        return true
      end
    else
      if figure_class::POSSIBLE_MOVES.include?(move)
        p "#{figure_class::POSSIBLE_MOVES}" if DEBUG
        return true
      end
    end
    false
  end

  def take_legal?(cords, figure_class, figure)
    current_cords = @current_tile.cords
    dx = (cords[0] - current_cords[0])
    dy = (cords[1] - current_cords[1])
    move = [dx, dy]
    p "move = #{move}" if DEBUG

    if figure_class::POSSIBLE_TAKES.include?(move)
        p "#{figure_class::POSSIBLE_TAKES}" if DEBUG
        return true
    end
    false
  end

  def move_line_clear?(target_cords, board)
    current_cords = @current_tile.cords

    #Knights King and Pawns have never blocked path
    return true if self.is_a?(Knight_white) || self.is_a?(Knight_black)
    return true if self.is_a?(King_white) || self.is_a?(King_black)
    return true if self.is_a?(Pawn_white) || self.is_a?(Pawn_black)

    dx = (target_cords[0] - current_cords[0]).clamp(-1, 1)
    dy = (target_cords[1] - current_cords[1]).clamp(-1, 1)

    check_x = current_cords[0] + dx
    check_y = current_cords[1] + dy

    # loop along the path but stop before the target tile
    while [check_x, check_y] != target_cords
      tile = board.grid[check_x][check_y]
      return false unless tile.empty? # path is blocked

      check_x += dx
      check_y += dy
    end
    true # path is clear
  end

  def move(target)
    current_tile = @current_tile
    figure = @current_tile.figure
    current_tile.figure = nil
    target.figure = figure
    figure.current_tile = target
    figure.first_move = false
    figure.sprite.x = target.draw_cords[:x]
    figure.sprite.y = target.draw_cords[:y]
  end


  def first_move?
    @first_move
  end

  def remove(board)
    to_remove = @current_tile.figure
    to_remove.sprite.remove
    @current_tile.figure = nil
    board.figures.delete(to_remove)
  end

  def take(target, board)
    figure = @current_tile.figure
    current_tile = @current_tile
    if take_legal?(target.cords, figure.class, figure)
      current_tile.figure = nil
      target_figure = target.figure
      target_figure.remove(board)
      target.figure = figure
      figure.current_tile = target
      figure.first_move = false
      figure.sprite.x = target.draw_cords[:x]
      figure.sprite.y = target.draw_cords[:y]
    else
      p "illegal take"
    end
  end
end