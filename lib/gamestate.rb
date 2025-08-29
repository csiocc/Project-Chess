require_relative "check"
module Game_states
  DEBUG = true
  #Gamestate management
  @selected_tile = nil

 
  def self.selected_tile #getter method for other modules/classes
    @selected_tile
  end

### Game State Methods ###

# when :white_turn #select figure
  def select_figure_white(clickd_tile, board)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return :white_turn
    end
    unless clickd_tile.empty? #if clicked outside of the board
      if clickd_tile.figure.color == "white"
        @selected_tile = clickd_tile
        p "#{clickd_tile.figure.class} selected"
        return :select_target_tile_white
      elsif clickd_tile.figure.color == "black"
        p "falsche farbe"
        return :white_turn #return to self
      end
    else
      p "Empty tile clicked, chose a Figure!"
      return :white_turn #return to self
    end
  end

# when :select_target_tile_white #select target tile
  def select_target_tile_white(clickd_tile, board)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return :select_target_tile_white
    end
    figure = @selected_tile.figure
    if clickd_tile.empty? #if clicked outside of the board
      if figure.valid_move?(clickd_tile.cords) #continue if move is legal
        if Valid_moves.los(@selected_tile.cords, clickd_tile.cords, board) #continue if move line is clear
          if figure.first_move?
            if figure.class == Pawn_white || figure.class == Pawn_black #special rule for pawn en passant
              figure.move(clickd_tile, board)
              figure.en_passant = true if figure.en_passant?(clickd_tile.cords)
              @selected_tile = nil
              return check_status_black(board.black_king_pos, board)
            else 
              figure.move(clickd_tile, board)
              @selected_tile = nil
              return check_status_black(board.black_king_pos, board)
            end
          else
            figure.move(clickd_tile, board)
            @selected_tile = nil
            return check_status_black(board.black_king_pos, board)
          end
        else
          p "something is blocking your path!"
          return :select_target_tile_white #return to self
        end
      else
        p "Please chose a legal move!"
        return :select_target_tile_white #return to self
      end
    else
      if clickd_tile.figure.color == "black" && figure.move_line_clear?(clickd_tile.cords, board) && figure.take_legal?(clickd_tile.cords, figure.class, figure, board)  
        figure.take(clickd_tile, board)
        @selected_tile = nil
        return check_status_black(board.black_king_pos, board)
      elsif clickd_tile.figure.color == "white"
        p "dont target your own figures!"
        return :select_target_tile_white #return to self
      else
        p "something went wrong, try again"
        return :select_target_tile_white #return to self
      end
    end
  end

# when :black_turn #select figure
  def select_figure_black(clickd_tile, board)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return :black_turn
    end
    unless clickd_tile.empty? #if clicked outside of the board
      if clickd_tile.figure.color == "black"
        @selected_tile = clickd_tile
        p "#{clickd_tile.figure.class} selected"
        return :select_target_tile_black
      elsif clickd_tile.figure.color == "white"
        p "wrong color"
        return :black_turn #return to self
      end
    else
      p "Empty tile clicked, chose your Figure"
      return :black_turn #return to self
    end
  end

  # when :select_target_tile_black #select target tile
  def select_target_tile_black(clickd_tile, board)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return :select_target_tile_black
    end
    figure = @selected_tile.figure
    if clickd_tile.empty? #if clicked outside of the board
      if figure.valid_move?(clickd_tile.cords) #continue if move is legal
        if figure.move_line_clear?(clickd_tile.cords, board) #continue if move line is clear
          if figure.first_move?
            if figure.class == Pawn_white || figure.class == Pawn_black #special rule for pawn en passant
              figure.move(clickd_tile, board)
              figure.en_passant = true if figure.en_passant?(clickd_tile.cords)
              @selected_tile = nil
              return check_status_white(board.white_king_pos, board)
            else 
              figure.move(clickd_tile, board)
              @selected_tile = nil
              return check_status_white(board.white_king_pos, board)
            end
          else
            figure.move(clickd_tile, board)
            @selected_tile = nil
            return check_status_white(board.white_king_pos, board)
          end
        else
          p "something is blocking your path!"
          return :select_target_tile_black #return to self
        end
      else
        p "Please chose a legal move!"
        return :select_target_tile_black #return to self
      end
    else
      if clickd_tile.figure.color == "white" &&figure.move_line_clear?(clickd_tile.cords, board) &&figure.take_legal?(clickd_tile.cords, figure.class, figure, board)  
        figure.take(clickd_tile, board)
        @selected_tile = nil
        @game_state = check_status_white(board.white_king_pos, board)
      elsif clickd_tile.figure.color == "black"
        p "dont target your own figures!"
        return :select_target_tile_black #return to self
      else
        p "something went wrong, try again"
        return :select_target_tile_black #return to self
      end
    end
  end

  # when :check_white
  def check_white
    white_figures = nil
  end
  


  # when :check_black
  





  ### Helpermethods ###

  def reset_en_passant_white(board)
    board.en_passant_reset_white
  end

  def reset_en_passant_black(board)
    board.en_passant_reset_black
  end

  def check_status_white(white_king_pos, board)
    if Check.check?(white_king_pos, board)
      return :check_white
    else
      return :white_turn
    end
  end

  def check_status_black(black_king_pos, board)
    if Check.check?(black_king_pos, board)
      p "check black true. Kingpos is:#{black_king_pos}" if DEBUG
      return :check_black
    else
      p "check black false. Kingpos is:#{black_king_pos}" if DEBUG
      return :black_turn
    end
  end



end