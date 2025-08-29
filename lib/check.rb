require_relative "figures"
require_relative "valid_moves"

module Check
  DEBUG = false
  include Valid_moves

  ### method to validate check ###
  def self.check?(king_cords, board)
    # define threats for the white king (from black pieces)
    king = board.grid[king_cords[0]][king_cords[1]].figure
    return false unless king&.is_a?(King)
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
    end
    

    threats.each do |figure_type, info|
      figure_class = info[:class]
      current_figure = (figure_type == :pawn) ? "bptake" : figure_type.to_s

      is_in_check = Valid_moves.targets(current_figure, king_cords).any? do |r, c|
        next unless board.grid[r][c].figure&.is_a?(figure_class)

        if info[:los]
          Valid_moves.los([r, c], king_cords, board)
        else
          true # figures that dont need los check (knight, pawn)
        end
      end

      return true if is_in_check
    end

    false # no check detected
  end

end
