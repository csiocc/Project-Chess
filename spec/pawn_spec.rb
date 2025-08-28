require_relative '../lib/pawn'
require_relative '../lib/board'
require_relative '../lib/figures'
require "rspec"
system 'clear'

describe Pawn_white do
  before do
    @board = Board.new
    @board.setup
    @board.setup_figures
  end

  describe '#move_legal? white' do
    it 'returns true for a valid single step forward' do
      cords = [2, 1]
      cords2 = [3, 1]
      pawn = @board.grid[1][1].figure
      expect(pawn.move_legal?(cords, Pawn_white, pawn)).to be true
      expect(pawn.move_legal?(cords2, Pawn_white, pawn)).to be true
    end
  end

  describe "#move_legal? white" do
   it "returns false for 3 steps forward" do
     cords = [4, 1]
     pawn = @board.grid[1][1].figure
     expect(pawn.move_legal?(cords, Pawn_white, pawn)).to be false  
   end
  end
end

describe Pawn_black do
  before do
    @board = Board.new
    @board.setup
    @board.setup_figures
  end

    describe '#move_legal? black' do
    it 'returns true for a valid single step forward or double step for first move' do
      cords = [5, 1]
      cords2 = [4, 1]
      pawn = @board.grid[6][1].figure
      expect(pawn.move_legal?(cords, Pawn_black, pawn)).to be true
      expect(pawn.move_legal?(cords2, Pawn_black, pawn)).to be true
    end
  end

  describe "#move_legal? white" do
   it "returns false for 3 steps forward" do
     cords = [2, 1]
     pawn = @board.grid[6][1].figure
     expect(pawn.move_legal?(cords, Pawn_black, pawn)).to be false  
   end
  end

  describe "move_line_clear? pawn 2 steps forward nothing in line" do
    it "returns true if line is clear" do
      cords = [3, 1]
      pawn = @board.grid[1][1].figure
      expect(pawn.move_line_clear?(cords, @board)).to be true
    end
  end


end
