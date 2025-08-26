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

  def take_legal?(cords, figure_class, figure, board)
    current_cords = @current_tile.cords
    dx = (cords[0] - current_cords[0])
    dy = (cords[1] - current_cords[1])
    move = [dx, dy]
    p "move = #{move}" if DEBUG

    if figure_class::POSSIBLE_TAKES.include?(move)
      p "#{figure_class::POSSIBLE_TAKES}" if DEBUG
      return true
    elsif figure_class == Pawn_white || figure_class == Pawn_black  #if pawn check for en_passant take
      possibility_one = board.grid[(current_cords[0]), (current_cords[1] + 1)]
      possibility_two = board.grid[current_cords[0],(current_cords[1] - 1)]
      return false if possibility_one.class == Array || possibility_two.class == Array
      if possibility_one.figure == Pawn_white || possibility_one.figure == Pawn_black
        return true
      elsif possibility_two.figure == Pawn_white || possibility_two.figure == Pawn_black
        return true
      end
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

  def en_passant?(cords)
    current_cords = @current_tile.cords
    dx = (cords[0] - current_cords[0])
    dy = (cords[1] - current_cords[1])
    move = [dx, dy]
    if move == [2, 0] || move == [-2, 0]
      return true
    end
    false
  end
  
  def move(target, board)
    current_tile = @current_tile
    figure = @current_tile.figure
    if figure.class == Pawn_white || figure.class == Pawn_black
      if figure.first_move?
        if en_passant?(target.cords)
          create_en_passant_clone(target, board)
        end
      end
    end
    current_tile.figure = nil
    target.figure = figure
    figure.current_tile = target
    figure.first_move = false
    figure.sprite.x = target.draw_cords[:x]
    figure.sprite.y = target.draw_cords[:y]
  end

  def create_en_passant_clone(target, board)
    figure = @current_tile.figure
    tile_to_set_clone_cords = []
    if figure.class == Pawn_white
      tile_to_set_clone_cords = [(target.cords[0] - 1), target.cords[1]]
    elsif figure.class == Pawn_black
      tile_to_set_clone_cords = [(target.cords[0] + 1), target.cords[1]]
    end
    tile_to_set_clone = board.grid[tile_to_set_clone_cords[0]][tile_to_set_clone_cords[1]] 
    tile_to_set_clone.figure = @current_tile.figure
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
    if take_legal?(target.cords, figure.class, figure, board)
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