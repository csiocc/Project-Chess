require_relative "figures"
require_relative "valid_moves"

module Check
  DEBUG = false
  include Valid_moves

  ### method to validate check ###
  def self.check?(cords, board, threat_color = nil)
    threatened_color = threat_color

    if threatened_color.nil?
      figure = board.grid[cords[0]][cords[1]].figure
      return false unless figure&.is_a?(King)
      threatened_color = figure.color
    end

    attacker_color = (threatened_color == "white") ? "black" : "white"

    #define threats by kings color

    threats = (attacker_color == "black") ?
      { 
        queen: { class: Queen_black, los: true },
        rook: { class: Rook_black, los: true },
        bishop: { class: Bishop_black, los: true },
        knight: { class: Knight_black, los: false },
        pawn: { class: Pawn_black, los: false }
      } :
      {
        queen: { class: Queen_white, los: true },
        rook: { class: Rook_white, los: true },
        bishop: { class: Bishop_white, los: true },
        knight: { class: Knight_white, los: false },
        pawn: { class: Pawn_white, los: false }
      }
    

    threats.each do |figure_type, info|
      figure_class = info[:class]
      figure_key = figure_type.to_s
      if figure_type == :pawn
        figure_key = (attacker_color == "white") ? "wptake" : "bptake"
      end

      attacker_tiles = Valid_moves.attacker_source(figure_key, cords)

      is_in_check = attacker_tiles.any? do |r, c|
        threatening_piece = board.grid[r][c].figure
        next unless threatening_piece&.is_a?(figure_class)

        #los check
        if info[:los]
          Valid_moves.los([r, c], cords, board)
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
    false # no check detected
  end

end
