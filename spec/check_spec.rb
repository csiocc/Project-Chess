
require 'rspec'
require_relative '../lib/board'
require_relative '../lib/check'
require_relative '../lib/valid_moves'
require_relative '../lib/figures'
require_relative '../lib/pawn'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'

describe Check do
  let(:board) { Board.new }
  let(:white_king) { King_white.new }

  before do
    # Clear the board for each test
    board.grid.each do |row|
      row.each do |tile|
        tile.figure = nil
      end
    end
    # Place the white king for testing
    board.grid[3][3].figure = white_king
    white_king.current_tile = board.grid[3][3]
    # Build the move targets
    Valid_moves.build_targets
  end

  describe '.check?' do
    let(:king_cords) { [3, 3] }

    context 'when the king is in check' do
      it 'detects check by a rook' do
        board.grid[3][0].figure = Rook_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'detects check by a bishop' do
        board.grid[0][0].figure = Bishop_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'detects check by a queen (diagonally)' do
        board.grid[5][5].figure = Queen_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'detects check by a queen (horizontally)' do
        board.grid[3][7].figure = Queen_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'detects check by a knight' do
        board.grid[1][2].figure = Knight_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'detects check by a pawn' do
        board.grid[4][2].figure = Pawn_black.new 
        expect(Check.check?(king_cords, board)).to be true
      end
    end

    context 'when the king is NOT in check' do
      it 'returns false for an empty board' do
        # King is on the board, but no other Figures
        king_only_board = Board.new
        king_only_board.grid.each { |r| r.each { |t| t.figure = nil } }
        king_only_board.grid[3][3].figure = white_king
        white_king.current_tile = king_only_board.grid[3][3]
        expect(Check.check?(king_cords, king_only_board)).to be false
      end

      it 'returns false when the line of sight is blocked' do
        board.grid[3][0].figure = Rook_black.new
        board.grid[3][1].figure = Pawn_white.new # Blocker
        expect(Check.check?(king_cords, board)).to be false
      end

      it 'returns false when a threatening-position piece is of the same color' do
        board.grid[3][0].figure = Rook_white.new
        expect(Check.check?(king_cords, board)).to be false
      end
    end

    context 'when the king is NOT in check because of blocking Figures' do
      it 'returns false for a rook when the path is blocked' do
        board.grid[3][0].figure = Rook_black.new
        board.grid[3][2].figure = Pawn_white.new # Blocker
        expect(Check.check?(king_cords, board)).to be false
      end

      it 'returns false for a bishop when the path is blocked' do
        board.grid[0][0].figure = Bishop_black.new
        board.grid[1][1].figure = Pawn_white.new # Blocker
        expect(Check.check?(king_cords, board)).to be false
      end

      it 'returns false for a queen (horizontally) when the path is blocked' do
        board.grid[3][7].figure = Queen_black.new
        board.grid[3][5].figure = Pawn_white.new # Blocker
        expect(Check.check?(king_cords, board)).to be false
      end

      it 'returns false for a queen (diagonally) when the path is blocked' do
        board.grid[5][5].figure = Queen_black.new
        board.grid[4][4].figure = Pawn_white.new # Blocker
        expect(Check.check?(king_cords, board)).to be false
      end
    end

    context 'with more complex scenarios' do
      it 'detects check when king is on the edge' do
        board.grid[3][3].figure = nil # Clear center king
        board.grid[0][4].figure = white_king
        white_king.current_tile = board.grid[0][4]
        board.grid[0][0].figure = Rook_black.new
        expect(Check.check?([0, 4], board)).to be true
      end

      it 'detects check when king is in a corner' do
        board.grid[3][3].figure = nil # Clear center king
        board.grid[0][0].figure = white_king
        white_king.current_tile = board.grid[0][0]
        board.grid[2][2].figure = Bishop_black.new
        expect(Check.check?([0, 0], board)).to be true
      end

      it 'detects a double check' do
        # King at [3,3] is checked by a bishop at [1,1]
        # and a rook at [3,0]
        board.grid[1][1].figure = Bishop_black.new
        board.grid[3][0].figure = Rook_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'detects pawn check from the other attack square' do
        # From [3,3], a black pawn can attack from [2,2] or [2,4]
        # The other test covers [2,2], this one covers [2,4]
        board.grid[4][4].figure = Pawn_black.new
        expect(Check.check?(king_cords, board)).to be true
      end

      it 'returns false when the path is blocked by multiple Figures' do
        board.grid[0][0].figure = Bishop_black.new
        board.grid[1][1].figure = Pawn_white.new # Blocker 1
        board.grid[2][2].figure = Pawn_black.new # Blocker 2
        expect(Check.check?(king_cords, board)).to be false
      end

      it 'returns true for a knight even when blocked (knights jump)' do
        # This is a sanity check, knights jump over Figures.
        board.grid[1][2].figure = Knight_black.new
        board.grid[2][2].figure = Pawn_white.new # This piece should not block the knight
        expect(Check.check?(king_cords, board)).to be true
      end
    end
  end
end