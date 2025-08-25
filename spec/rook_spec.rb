require_relative '../lib/pawn'
require_relative '../lib/board'
require_relative '../lib/figures'
system 'clear'

describe Rook_white do
  before do
    @board = Board.new
    @board.setup
    @board.setup_figures
  end
    describe "move_line_clear? rook 2 steps forward pawn in between" do
    it "returns false if line is not clear" do
      cords = [4, 0]
      rook = @board.grid[0][0].figure
      expect(rook.move_line_clear?(cords, @board)).to be false
    end
  end

  describe "move_line_clear? rook 2 steps right should return false" do
    it "returns false if line is not clear" do
      cords = [0, 4]
      rook = @board.grid[0][0].figure
      expect(rook.move_line_clear?(cords, @board)).to be false
    end
  end

  
end