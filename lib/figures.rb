require_relative "valid_moves"
#class for all figures for shared functions


class Figures
  DEBUG = false
  include Valid_moves
  attr_reader :color

  def setup(tile)
    @current_tile = tile
    @sprite.x = tile.draw_cords[:x]
    @sprite.y = tile.draw_cords[:y]
  end

  def valid_move?(cords)
    valid_moves = []
    current_cords = @current_tile.cords
    valid_moves = Valid_moves.valid_moves(@current_tile.figure.class, current_cords)
    p "Valid moves = #{valid_moves}" if DEBUG
    p "Cords = #{cords}" if DEBUG
    return true if valid_moves.include?(cords)
    false
  end

  def take_legal?(cords, figure_class, figure, board)
    current_cords = @current_tile.cords
    if Valid_moves.valid_takes(figure_class, current_cords).include?(cords)
      return true
    elsif figure_class == Pawn_white || figure_class == Pawn_black  #if pawn check for en_passant take
      p "Valid takes = #{Valid_moves.valid_takes(figure_class, current_cords)}" if DEBUG
      p "cords = #{cords}" if DEBUG
      cords if DEBUG
      if Valid_moves.valid_takes(figure_class, current_cords).include?(cords) 
        possibility_one = board.grid[current_cords[0], (current_cords[1] + 1)]
        possibility_two = board.grid[current_cords[0],(current_cords[1] - 1)]
        if possibility_one.class == Array || possibility_two.class == Array
          return false
        elsif possibility_two.figure == Pawn_white || possibility_two.figure == Pawn_black
          return true
        end
        return true
      end
    else
      return true if valid_move?(cords)
    end
    false
  end

  def move_line_clear?(target_cords, board)
    current_cords = @current_tile.cords

    #Knights King and Pawns have never blocked path
    return true if self.is_a?(Knight_white) || self.is_a?(Knight_black)
    return true if self.is_a?(King_white) || self.is_a?(King_black)
    return true if self.is_a?(Pawn_white) || self.is_a?(Pawn_black)
    return true if Valid_moves.los(current_cords, target_cords, board)
    false
  end

  ### detects en_passant vulnerability ###
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

  ### creates an en_passant_clone to target the right figure on an en_passant move ###
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
    tile_to_set_clone.en_passant_clone = true
  end

  def move(target, board)
    p "move called" if DEBUG
    current_tile = @current_tile
    figure = @current_tile.figure

    #creates en_passant clone betwen start and target if moved 2 tiles
    if figure.class == Pawn_white || figure.class == Pawn_black 
      if figure.first_move?
        if en_passant?(target.cords)
          create_en_passant_clone(target, board)
        end
      end
    end
    #moves the figure to target tile
    current_tile.figure = nil
    target.figure = figure
    target.en_passant_clone = false if target.en_passant_clone #prevents figure deleting if moved to a Tile with existing en_passant clone
    figure.current_tile = target
    figure.first_move = false
    figure.sprite.x = target.draw_cords[:x]
    figure.sprite.y = target.draw_cords[:y]
  end



  def first_move?
    @first_move
  end

  ###permanentely removes a figure from the board###
  def remove(board)
    to_remove = @current_tile.figure
    to_remove.sprite.remove
    @current_tile.figure = nil
    board.figures.delete(to_remove)
  end

  ### checks if targettile stores an en_passant clone if yes and figure is not pawn changes take to move to not 
  #accidentaly delete clones parrent###
  def take_en_passant_check?(target, board, figure)
    p "take_en_passant_check called" if DEBUG
    p "target tile enpassant status is #{target.en_passant_clone}" if DEBUG
    p "figure.class is #{figure.class}" if DEBUG
    p "figure.class != Pawn_white is #{figure.class != Pawn_white}" if DEBUG
    p "figure.class != Pawn_black is #{figure.class != Pawn_black}" if DEBUG
    if figure.class != Pawn_white && figure.class != Pawn_black && target.en_passant_clone
      p "take_en_passant first if called ->move" if DEBUG
      figure.move(target, board)
      return true
    else
      p "take_en_passant else called" if DEBUG
      return false
    end
  end

  def take(target, board)
    figure = @current_tile.figure
    current_tile = @current_tile
    if take_en_passant_check?(target, board, figure)
      p "take en passant escaper called" if DEBUG
    else
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
end