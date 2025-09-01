require_relative "check"

### i know i copyed most of the methods for black / white
#   a better aproach would be to just send the color as an argument to the method and make them interchangeable
#   for both colors. Next time.

module Game_states
  DEBUG = false
  DEBUG2 = false
  #Gamestate management
  @selected_tile = nil
  @pawn_to_promote = nil

 
  def self.selected_tile #getter method for other modules/classes
    @selected_tile
  end

  def self.pawn_to_promote #getter method for other modules/classes
    @pawn_to_promote
  end


### Game State Methods ###

# when :white_turn #select figure
  def self.select_figure_white(clickd_tile, board, valid_figures = nil)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return {status: :white_turn}
    end

    in_check = !valid_figures.nil?
    return_status = in_check ? :check_white : :white_turn

    if valid_figures.nil?
      valid_figures = board.white_figures
    end

    unless clickd_tile.empty? #if clicked outside of the board
      if clickd_tile.figure.color == "white" && valid_figures.include?(clickd_tile.figure)
        @selected_tile = clickd_tile
        p "#{clickd_tile.figure.class} selected" if DEBUG
        return {status: :select_target_tile_white}
      elsif clickd_tile.figure.color == "black"
        p "Wrong Color"
        return {status: :white_turn} #return to self
      end
    else
      p "Empty tile clicked, chose a Figure!"
      return {status: return_status} #return to self
    end
  end

# when :select_target_tile_white #select target tile
  def self.select_target_tile_white(clickd_tile, board)
    if clickd_tile.class == Array #emergency return if clicked right between 2 Tiles
      return {status: :select_target_tile_white}
    end
    figure = @selected_tile.figure
    current_cords = @selected_tile.cords
    target_cords = clickd_tile.cords

    is_valid_move = false
    is_capture = !clickd_tile.empty?



    #castle rule
    if figure.is_a?(King) && Valid_moves.valid_castle(figure.class, figure.current_tile.cords).include?(target_cords) 
      castle_result = Game_states.perform_castling(figure, target_cords, board)
      if castle_result[:error]
        p castle_result[:error] if DEBUG 
        return { status: :white_turn }
      else
        @selected_tile = nil
        return castle_result
      end
    end

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
    if Check.check?(king_pos_after_move, board, "white")
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
    #pawn promotion rule
    if figure.is_a?(Pawn_white) && target_cords[0] == 7
      @pawn_to_promote = figure
      return { status: :promote_pawn, color: "white" }
    end

    
    Game_states.reset_en_passant_black(board)
    return check_status("black", board)
  end

# when :black_turn #select figure
  def self.select_figure_black(clickd_tile, board, valid_figures = nil)
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
        p "#{clickd_tile.figure.class} selected" if DEBUG
        return {status: :select_target_tile_black}
      elsif clickd_tile.figure.color == "white"
        p "Wrong color"
        return {status: :black_turn} # return to self
      end
    else
      p "Empty tile clicked"
      return {status: return_status} # return to self
    end
  end

# when :select_target_tile_black #select target tile
  def self.select_target_tile_black(clickd_tile, board)
    if clickd_tile.class == Array # emergency return if clicked right between 2 Tiles
      return {status: :select_target_tile_black}
    end

    figure = @selected_tile.figure
    current_cords = @selected_tile.cords
    target_cords = clickd_tile.cords


    is_valid_move = false
    is_capture = !clickd_tile.empty?



    #castle rule
    if figure.is_a?(King) && Valid_moves.valid_castle(figure.class, figure.current_tile.cords).include?(target_cords)
      castle_result = Game_states.perform_castling(figure, target_cords, board)
      if castle_result[:error]
        p castle_result[:error] if DEBUG 
        return { status: :black_turn }
      else
        @selected_tile = nil
        return castle_result
      end
    end

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
    
    if Check.check?(king_pos_after_move, board, "black")
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
    #pawn promotion rule
    if figure.is_a?(Pawn_black) && target_cords[0] == 0
      @pawn_to_promote = figure
      return { status: :promote_pawn, color: "black" }
    end

    
    Game_states.reset_en_passant_white(board)
    return check_status("white", board)
  end


  # when :check
  def self.check_status(color, board)
    legal_moves = []
    king = (color == "white") ? board.figures.find { |f| f.is_a?(King_white) } : board.figures.find { |f| f.is_a?(King_black) }

    unless Check.check?(king.current_tile.cords, board, color)
      return {status: (color == "white" ? :white_turn : :black_turn), legal_moves: []}
    end
    
    figures_to_check = (color == "white") ? board.white_figures : board.black_figures
    enemy_color = (color == "white") ? "black" : "white"

    figures_to_check.each do |figure|
      current_cords = figure.current_tile.cords
      valid_moves = (Valid_moves.valid_moves(figure.class, current_cords) + Valid_moves.valid_takes(figure.class, current_cords)).uniq

      valid_moves.each do |move_cords|
        target_tile = board.grid[move_cords[0]][move_cords[1]]
        if target_tile.empty?
          is_valid_move = figure.valid_move?(move_cords)
        elsif target_tile.figure.color == enemy_color
          is_valid_move = figure.take_legal?(move_cords, figure.class, figure, board)
        end
      
        if is_valid_move && Valid_moves.los(current_cords, move_cords, board)
          king_pos_after_move = figure.is_a?(King) ? move_cords : king.current_tile.cords
          undo_info = board.move_simulation(figure, move_cords)
          if !Check.check?(king_pos_after_move, board, color)
            legal_moves << {figure: figure, from: current_cords, to: move_cords}
          else
            false
          end
          board.undo_simulation(undo_info)
        end      
      end
    end

    if legal_moves.empty?
      check_info = {status: (color == "white" ? :check_mate_white : :check_mate_black), legal_moves: legal_moves}
    else
      check_info = {status: (color == "white" ? :check_white : :check_black), legal_moves: legal_moves}
    end
    return check_info
  end
  
  def self.reset_en_passant_white(board)
    board.en_passant_reset_white
  end

  def self.reset_en_passant_black(board)
    board.en_passant_reset_black
  end

  #when :promote_pawn
  def self.handle_promotion(clickd_tile, board)
    pawn = self.pawn_to_promote
    return {status: :error } unless pawn
    color = pawn.color
    p " handle_promotion called for pawn at #{pawn.current_tile.cords} and color = #{color}" if DEBUG2
    p "clicked tile: #{clickd_tile.cords}, empty: #{clickd_tile.empty?}" if DEBUG2
    return {status: :promote_pawn, color: color} if clickd_tile.empty? #return to self if empty tile clicked

    chosen_figure =  clickd_tile.figure
    p "chosen figure: #{chosen_figure.class} (color: #{chosen_figure.color})" if DEBUG2
    #validation
    
    is_valid_choice = true
    
    if chosen_figure.color != color
      p "Please chose a Figure of your color"
      is_valid_choice = false
      p "Validation failed: Wrong color" if DEBUG2
    elsif chosen_figure.is_a?(King) || chosen_figure.is_a?(Pawn)
      p "U cant promote King / Pawn"
      is_valid_choice = false
      p "validation failed: king or pawn" if DEBUG2
    end

    if is_valid_choice
      #perform promotion if there is a valid choice
      p "validation passed calling promote_pawn" if DEBUG2
      chosen_class = chosen_figure.class
      board.promote_pawn(pawn, chosen_class)
      @pawn_to_promote = nil
      next_color_to_check = (color == "white") ? "black" : "white"
      result = self.check_status(next_color_to_check, board)
      return result[:status] || (next_color_to_check + "_turn").to_sym
    else
      p "validation failed returning to promote_pawn state" if DEBUG2
      return {status: :promote_pawn, color: color}
    end
  end

  ### Helpermethods ###

  private

  def self.perform_castling(king, target_cords, board)
    #rule 1 kings first move
    return {error: "King has allready moved"} unless king.first_move?
    #rule 2 king is not in check
    return {error: "U cant castle out of check"} if Check.check?(king.current_tile.cords, board, king.color)

    # wich castle, king or queen side?
    king_side = target_cords[1] == 6
    queen_side = target_cords[1] == 2

    return {error: "Invalid castle target"} unless king_side || queen_side

    # wich rook, rooks path and rooks destination based on color and side
    if king.color == "white"
      row = 0
      rook_c = king_side ? 7 : 0
      path_c = king_side ? [5, 6] : [1, 2, 3]
      tiles_to_check = king_side ? [5, 6] : [2, 3]
      rook_destination_c = king_side ? 5 : 3
    else #for black king
      row = 7
      rook_c = king_side ? 7 : 0
      path_c = king_side ? [5, 6] : [1, 2, 3]
      tiles_to_check = king_side ? [5, 6] : [2, 3]
      rook_destination_c = king_side ? 5 : 3
    end

    rook_tile = board.grid[row][rook_c]
    rook = rook_tile.figure

    #rule 3 rook must exist and its first move
    return {error: "Rook has allready moved or is not in the right position"} unless rook && rook.first_move?

    #rule 4 path between king and rook is not blocked
    path_c.each do |c|
      unless board.grid[row][c].empty?
        return {error: "Path is blocked u cant castle"}
      end
    end
    
    #rule 5 king does not pass through check
    tiles_to_check.each do |c|
      if Check.check?([row, c], board, king.color)
        return {error: "U cant castle through check"}
      end
    end

    # all checks passed
    king.move(board.grid[row][target_cords[1]], board)
    rook.move(board.grid[row][rook_destination_c], board)

    #returning success and next gamestate
    
    next_turn = king.color == "white" ? :black_turn : :white_turn
    return {status: next_turn}
  end



end