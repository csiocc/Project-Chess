require_relative "figures"
require_relative "valid_moves"

module Check
  DEBUG = true
  include Valid_moves

  ### method to validate check ###
  def self.check?(king_cords, board)
    # define threats for the white king (from black pieces)
    king = board.grid[king_cords[0]][king_cords[1]].figure

    
    #if there is no figure or no king it cant be check so return false
    return false unless king&.is_a?(King)

    #define threats by kings color
    if king.color == "white"
      threats = {
        queen: { class: Queen_black, los: true },
        rook: { class: Rook_black, los: true },
        bishop: { class: Bishop_black, los: true },
        knight: { class: Knight_black, los: false },
        pawn: { class: Pawn_black, los: false }
      }  
    elsif king.color == "black"
      threats = {
        queen: { class: Queen_white, los: true },
        rook: { class: Rook_white, los: true },
        bishop: { class: Bishop_white, los: true },
        knight: { class: Knight_white, los: false },
        pawn: { class: Pawn_white, los: false }
      }
    else
      p "this should never happen - king color not found -> else" if DEBUG
      return false 
    end
    

    threats.each do |figure_type, info|
      figure_class = info[:class]

      figure_key = figure_type.to_s

      if figure_type == :pawn
        figure_key = (king.color == "white") ? "bptake" : "wptake"
      end

      attacker_tiles = Valid_moves.attacker_source(figure_key, king_cords)

      is_in_check = attacker_tiles.any? do |r, c|
        threatening_piece = board.grid[r][c].figure
        next unless threatening_piece&.is_a?(figure_class)

        #los check
        if info[:los]
          Valid_moves.los([r, c], king_cords, board)
        else
          p "check detected" if DEBUG
          true
        end
      end

      if is_in_check
        p "check detected from #{figure_type}" if DEBUG
        return true
      end
    end

    p "no check detected" if DEBUG
    return false # no check detected
  end

end
