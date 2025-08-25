require_relative '../lib/figures'
require_relative '../lib/pawn'
require_relative '../lib/board'
system 'clear'

describe Figures do
  before do
    test = Board.new
    test.setup
    test.setup_figures
  end
  describe 'legal_move?'
    it 'returns true' do
      test.grid[1][1].move_legal?([2, 1])
      expect(test.grid[1][1].move_legal?([2, 1])).to be true)
    end
end