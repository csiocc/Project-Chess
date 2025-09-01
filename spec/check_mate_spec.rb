require 'rspec'
require_relative '../lib/board'
require_relative '../lib/gamestate'


class GameStateTester
  include Game_states
end

describe 'Checkmate' do
  let(:board) { Board.new }
  let(:game) { GameStateTester.new }
  let(:white_king) { King_white.new }
  let(:black_king) { King_black.new }

  before do
    Valid_moves.build_targets
    board.grid.each { |row| row.each { |tile| tile.figure = nil } }
    board.add_figure(white_king, [7, 4]) 
    board.add_figure(black_king, [0, 4])
  end

  context 'when it is true checkmate' do
    it 'detects a smothered mate with a knight' do

      board.move_figure([7, 4], [7, 7]) 
      board.add_figure(Rook_white.new, [7, 6]) 
      board.add_figure(Pawn_white.new, [6, 6]) 
      board.add_figure(Pawn_white.new, [6, 7]) 
      board.add_figure(Knight_black.new, [6, 5])

      result = game.check_status('white', board)
      expect(result[:status]).to eq(:check_mate_white)
      expect(result[:legal_moves].length).to eq(0)
    end
  end

  context 'when it is check, but NOT checkmate' do
    it 'detects that a queen mate is not real if the queen is unprotected' do
      board.move_figure([7, 4], [7, 7]) 
      board.add_figure(Queen_black.new, [6, 7]) 
      board.add_figure(King_black.new, [5, 5]) 

      result = game.check_status('white', board)
      expect(result[:status]).to eq(:check_white)
      expect(result[:legal_moves].length).to be > 0
    end

    it 'returns :check_white if the king can move to empty squares' do
      board.move_figure([7, 4], [7, 7])
      board.add_figure(Rook_black.new, [6, 7]) 


      result = game.check_status('white', board)
      expect(result[:status]).to eq(:check_white)
      expect(result[:legal_moves].length).to eq(2)
    end

    it 'returns :check_white if the attacking piece can be captured' do
      board.add_figure(Rook_black.new, [7, 0]) 
      board.add_figure(Rook_white.new, [0, 0]) 

      result = game.check_status('white', board)
      expect(result[:status]).to eq(:check_white)
      expect(result[:legal_moves].length).to be > 1
    end

    it 'returns :check_white if the check can be blocked' do
      board.move_figure([7, 4], [7, 0]) 
      board.add_figure(Bishop_black.new, [4, 3]) 
      board.add_figure(Bishop_white.new, [7, 5]) 

      result = game.check_status('white', board)
      expect(result[:status]).to eq(:check_white)
      expect(result[:legal_moves].length).to be > 1
    end
  end
end