
require 'rspec'
require_relative '../lib/board'
require_relative '../lib/valid_moves'
require_relative '../lib/figures'
require_relative '../lib/pawn'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'

describe Valid_moves do
  let(:board) { Board.new }

  before do
    # Clear the board for each test
    board.grid.each do |row|
      row.each do |tile|
        tile.figure = nil
      end
    end
    # build targets needed for los
    Valid_moves.build_targets
  end

  describe '.los' do
    context 'when the path is clear' do
      it 'returns true for a vertical path' do
        expect(Valid_moves.los([0, 0], [5, 0], board)).to be true
      end

      it 'returns true for a horizontal path' do
        expect(Valid_moves.los([0, 0], [0, 5], board)).to be true
      end

      it 'returns true for a diagonal path' do
        expect(Valid_moves.los([0, 0], [5, 5], board)).to be true
      end
    end

    context 'when the path is blocked' do
      it 'returns false for a vertical path' do
        board.grid[2][0].figure = Pawn_white.new
        expect(Valid_moves.los([0, 0], [5, 0], board)).to be false
      end

      it 'returns false for a horizontal path' do
        board.grid[0][2].figure = Pawn_white.new
        expect(Valid_moves.los([0, 0], [0, 5], board)).to be false
      end

      it 'returns false for a diagonal path' do
        board.grid[2][2].figure = Pawn_white.new
        expect(Valid_moves.los([0, 0], [5, 5], board)).to be false
      end
    end

    context 'with edge cases' do
      it 'returns true when the path has length 1' do
        expect(Valid_moves.los([0, 0], [0, 1], board)).to be true
      end

      it 'returns false when current and target are the same' do
        expect(Valid_moves.los([0, 0], [0, 0], board)).to be false
      end

      it 'returns true when the target tile is occupied but the path is clear' do
        board.grid[5][0].figure = Pawn_black.new
        expect(Valid_moves.los([0, 0], [5, 0], board)).to be true
      end

      it 'returns false for a non-linear (L-shape) path' do
        # This is not a straight line, so los should be false
        expect(Valid_moves.los([0, 0], [2, 1], board)).to be false
      end
    end
  end
end
