require_relative "check"

### i know i copyed most of the methods for black / white
#   a better aproach would be to just send the color as an argument to the method and make them interchangeable
#   for both colors. Next time.

module Game_states
  DEBUG = true
  #Gamestate management
  @selected_tile = nil

 
  def self.selected_tile #getter method for other modules/classes
    @selected_tile
  end

### Game State Methods ###

# when :white_turn #select figure
  def select_figure_white(clickd_tile, board, valid_figures = nil)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return {status: :white_turn}
    end

    in_check = !valid_figures.nil?
    return_status = in_check ? :check_black : :black_turn

    if valid_figures.nil?
      valid_figures = board.white_figures
    end

    unless clickd_tile.empty? #if clicked outside of the board
      if clickd_tile.figure.color == "white" && valid_figures.include?(clickd_tile.figure)
        @selected_tile = clickd_tile
        p "#{clickd_tile.figure.class} selected"
        return {status: :select_target_tile_white}
      elsif clickd_tile.figure.color == "black"
        p "falsche farbe"
        return {status: :white_turn} #return to self
      end
    else
      p "Empty tile clicked, chose a Figure!"
      return {status: return_status} #return to self
    end
  end

# when :select_target_tile_white #select target tile
  def select_target_tile_white(clickd_tile, board)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return {status: :select_target_tile_white}
    end
    figure = @selected_tile.figure
    current_cords = @selected_tile.cords
    target_cords = clickd_tile.cords

    is_valid_move = false
    is_capture = !clickd_tile.empty?

    if is_capture
      if clickd_tile.figure.color == "black" && figure.take_legal?(target_cords, figure.class, figure, board)
        is_valid_move = true
      end
    else #move to empty square
      is_valid_move = figure.valid_move?(target_cords)
    end

    #los check
    is_valid_move &&= Valid_moves.los(current_cords, target_cords, board)

    unless is_valid_move
      p "Invalid move!"
      return {status: :select_target_tile_white}
    end

    #check if the move would cause a check
    king = board.figures.find { |f| f.is_a?(King_white) }
    king_pos_after_move = figure.is_a?(King) ? target_cords : king.current_tile.cords
    
    undo_info = board.move_simulation(figure, target_cords)
    if Check.check?(king_pos_after_move, board)
      p "move denied because of check"
      board.undo_simulation(undo_info)
      return {status: :select_target_tile_white, valid_figures: []}
    end

    # move is legal, undo sim and perform real move
    board.undo_simulation(undo_info)
    
    if is_capture
      figure.take(clickd_tile, board)
    else
      figure.move(clickd_tile, board)
    end

    # pawn special en passsant logic
    if figure.is_a?(Pawn) && figure.first_move?
      figure.en_passant = true if figure.en_passant?(target_cords)
    end

    @selected_tile = nil
    Game_states.reset_en_passant_black(board)
    return check_status("black", board)
  end

# when :black_turn #select figure
  def select_figure_black(clickd_tile, board, valid_figures = nil)
    if clickd_tile.class == Array # emergency return if clicked right between 2 Tiles
      return {status: :black_turn}
    end

    in_check = !valid_figures.nil?
    return_status = in_check ? :check_black : :black_turn

    
    if valid_figures.nil?
      valid_figures = board.black_figures
    end

    unless clickd_tile.empty? # if clicked outside of the board
      if clickd_tile.figure.color == "black" && valid_figures.include?(clickd_tile.figure)
        @selected_tile = clickd_tile
        p "#{clickd_tile.figure.class} selected"
        return {status: :select_target_tile_black}
      elsif clickd_tile.figure.color == "white"
        p "falsche farbe"
        return {status: :black_turn} # return to self
      end
    else
      p "Empty tile clicked, chose a Figure!"
      return {status: return_status} # return to self
    end
  end

# when :select_target_tile_black #select target tile
  def select_target_tile_black(clickd_tile, board)
    if clickd_tile.class == Array # emergency return if clicked right between 2 Tiles
      return {status: :select_target_tile_black}
    end

    figure = @selected_tile.figure
    current_cords = @selected_tile.cords
    target_cords = clickd_tile.cords


    is_valid_move = false
    is_capture = !clickd_tile.empty?

    if is_capture
      if clickd_tile.figure.color == "white" && figure.take_legal?(target_cords, figure.class, figure, board)
        is_valid_move = true
      end
    else
      is_valid_move = figure.valid_move?(target_cords)
    end

   
    is_valid_move &&= Valid_moves.los(current_cords, target_cords, board)

    unless is_valid_move
      p "Invalid move!"
      return {status: :select_target_tile_black}
    end


    king = board.figures.find { |f| f.is_a?(King_black) }
    king_pos_after_move = figure.is_a?(King) ? target_cords : king.current_tile.cords
    
    undo_info = board.move_simulation(figure, target_cords)
    
    if Check.check?(king_pos_after_move, board)
      p "You can't make a move that leaves your king in check."
      board.undo_simulation(undo_info)
      return {status: :select_target_tile_black}
    end
    

    board.undo_simulation(undo_info)

    if is_capture
      figure.take(clickd_tile, board)
    else
      figure.move(clickd_tile, board)
    end
    

    if (figure.is_a?(Pawn_white) || figure.is_a?(Pawn_black)) && figure.first_move?
        figure.en_passant = true if figure.en_passant?(target_cords)
    end

    @selected_tile = nil
    Game_states.reset_en_passant_white(board)
    return check_status("white", board)
  end


  # when :check
  def check_status(color, board)
    legal_moves = []
    check_info = {status: nil, legal_moves: legal_moves}
    
    case color
    when "white"
      king = board.figures.find { |f| f.is_a?(King_white) }
      return {status: :white_turn, legal_moves: nil} unless Check.check?(king.current_tile.cords, board)

      p "check status white entered" if DEBUG
      board.white_figures.each do |figure|
        current_cords = figure.current_tile.cords
        
        # get all possible moves and takes for figure
        candidate_moves = (
          Valid_moves.valid_moves(figure.class, current_cords) +
          Valid_moves.valid_takes(figure.class, current_cords)
        ).uniq

        candidate_moves.each do |move_cords|
 
          # next unless move_cords[0].between?(0, 7) && move_cords[1].between?(0, 7)
          
          target_tile = board.grid[move_cords[0]][move_cords[1]]

          is_valid_move = false
          if target_tile.empty?
            # if its a move check for valid_move?
            is_valid_move = figure.valid_move?(move_cords)
          elsif target_tile.figure.color == "black"
            # if its a take check for take_legal?
            is_valid_move = figure.take_legal?(move_cords, figure.class, figure, board)
          end

          # check los
          if is_valid_move && Valid_moves.los(current_cords, move_cords, board)
            undo_info = board.move_simulation(figure, move_cords)
            if !Check.check?(king.current_tile.cords, board)
              legal_moves << { figure: figure, from: current_cords, to: move_cords }
            end
            board.undo_simulation(undo_info)
          end
        end
      end
      
      if legal_moves.empty?
        check_info = {status: :check_mate_white, legal_moves: legal_moves}
      else
        check_info = {status: :check_white, legal_moves: legal_moves}
      end

    when "black"
      king = board.figures.find { |f| f.is_a?(King_black) }
      return {status: :black_turn, legal_moves: nil} unless Check.check?(king.current_tile.cords, board)

      p "check status black entered" if DEBUG
      board.black_figures.each do |figure|
        current_cords = figure.current_tile.cords

        candidate_moves = (
          Valid_moves.valid_moves(figure.class, current_cords) +
          Valid_moves.valid_takes(figure.class, current_cords)
        ).uniq

        candidate_moves.each do |move_cords|
          next unless move_cords[0].between?(0, 7) && move_cords[1].between?(0, 7)

          target_tile = board.grid[move_cords[0]][move_cords[1]]

          is_valid_move = false
          if target_tile.empty?
            is_valid_move = figure.valid_move?(move_cords)
          elsif target_tile.figure.color == "white"
            is_valid_move = figure.take_legal?(move_cords, figure.class, figure, board)
          end

          if is_valid_move && Valid_moves.los(current_cords, move_cords, board)
            undo_info = board.move_simulation(figure, move_cords)
            if !Check.check?(king.current_tile.cords, board)
              legal_moves << { figure: figure, from: current_cords, to: move_cords }
            end
            board.undo_simulation(undo_info)
          end
        end
      end

      p "legal moves are: #{legal_moves}" if DEBUG
      if legal_moves.empty?
        check_info = {status: :check_mate_black, legal_moves: legal_moves}
      else
        check_info = {status: :check_black, legal_moves: legal_moves}
      end
    end
    
    return check_info
  end
  

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