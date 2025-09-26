require_relative "../figures/figures"
require_relative "valid_moves"

module Check
  DEBUG = false
  include Valid_moves

  ### method to validate check ###
  def self.check?(cords, board, threat_color = nil)
    rc = xy(cords)  

    threatened_color = threat_color
    if threatened_color.nil?
      figure = board.grid[rc[0]][rc[1]].figure
      return false unless figure&.is_a?(King)
      threatened_color = figure.color
    end

    attacker_color = (threatened_color == "white") ? "black" : "white"

    threats = (attacker_color == "black") ?
      {
        queen:  { class: Queen_black,  los: true  },
        rook:   { class: Rook_black,   los: true  },
        bishop: { class: Bishop_black, los: true  },
        knight: { class: Knight_black, los: false },
        pawn:   { class: Pawn_black,   los: false }
      } :
      {
        queen:  { class: Queen_white,  los: true  },
        rook:   { class: Rook_white,   los: true  },
        bishop: { class: Bishop_white, los: true  },
        knight: { class: Knight_white, los: false },
        pawn:   { class: Pawn_white,   los: false }
      }

    threats.each do |figure_type, info|
      figure_key = (figure_type == :pawn) ? ((attacker_color == "white") ? "wptake" : "bptake") : figure_type.to_s
      attacker_tiles = Valid_moves.attacker_source(figure_key, rc)
      is_in_check = attacker_tiles.any? do |r, c|
        next if r < 0 || c < 0 || r >= board.grid.length || c >= board.grid[0].length

        threatening_figure = board.grid[r][c].figure
        next unless threatening_figure&.is_a?(info[:class])

        if info[:los]
          Valid_moves.los([r, c], rc, board) 
        else
          true
        end
      end

      return true if is_in_check
    end
    false
  end

def self.xy(pos)

  if pos.is_a?(Array)
    if pos.size >= 2 && pos[0].is_a?(Integer) && pos[1].is_a?(Integer)
      return [pos[0], pos[1]]
    end
    return xy(pos.first)

  end

  if pos.is_a?(Hash)
    x = pos[:x] || pos['x']
    y = pos[:y] || pos['y']
    return [y, x]
  end

  return xy(pos.cords)  if pos.respond_to?(:cords)
  return xy(pos.coords) if pos.respond_to?(:coords)

  if pos.respond_to?(:current_tile) && pos.current_tile
    return xy(pos.current_tile.cords) if pos.current_tile.respond_to?(:cords)
    if pos.current_tile.respond_to?(:x) && pos.current_tile.respond_to?(:y)
      return [pos.current_tile.y, pos.current_tile.x]
    end
  end

  if pos.respond_to?(:x) && pos.respond_to?(:y)
    return [pos.y, pos.x]
  end

  raise TypeError, "Unknown coord format for Check.xy: #{pos.inspect}"
end



end
