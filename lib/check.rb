require_relative "figures"
require_relative "valid_moves"

module Check
  DEBUG = false
  include Valid_moves

  def self.test(current_cords, board)
    p "current cords are #{current_cords}" if DEBUG
    p Valid_moves.targets("queen", current_cords) if DEBUG
    queen_pos = Valid_moves.targets("queen", current_cords).find do |(r, c)|
      p "r is #{r} and c is #{c}"
      board.grid[r][c].figure&.is_a?(Queen)
    end
    p "Position der Dame ist: #{queen_pos}"
  end

  ### method to validate check ###
  def self.check?(king_cords, board)
    # Define threats for the white king (from black pieces)
    threats = {
      queen: { class: Queen_black, los: true },
      rook: { class: Rook_black, los: true },
      bishop: { class: Bishop_black, los: true },
      knight: { class: Knight_black, los: false },
      pawn: { class: Pawn_black, los: false }
    }

    threats.each do |figure_type, threat_info|
      figure_class = threat_info[:class]
      targets_method = (figure_type == :pawn) ? "bptake" : figure_type.to_s

      is_in_check = Valid_moves.targets(targets_method, king_cords).any? do |r, c|
        next unless board.grid[r][c].figure&.is_a?(figure_class)

        if threat_info[:los]
          Valid_moves.los([r, c], king_cords, board)
        else
          true # For pieces that don't need line-of-sight check (knight, pawn)
        end
      end

      return true if is_in_check
    end

    false # No check detected
  end

  def check_mate?
    
  end

end
