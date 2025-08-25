#class for all figures for shared functions
DEBUG = false

class Figures 
  def move_legal?(cords, figure_class, figure = nil)
    current_cords = @current_tile.cords
    dx = (cords[0] - current_cords[0])
    dy = (cords[1] - current_cords[1])
    move = [dx, dy]
    p "move = #{move}" if DEBUG

    if figure.first_move?
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

  def move_line_clear?(target, board)
    current_cords = @current_tile.cords
    target_cords = target
    current_xd = current_cords[0]
    current_yd = current_cords[1]
    target_xd = target_cords[0]
    target_yd = target_cords[1]
    to_check = []


    x_range = current_xd..target_xd
    y_range = current_yd..target_yd

    board.grid[x_range].each do |array|
      array[y_range].each do |tile|
        to_check << tile
      end
    end

    to_check.shift
    to_check.each do |tile|
      if !tile.empty?
        return false
      end
    end
    true
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


end