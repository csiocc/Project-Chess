require 'rspec'
require_relative '../lib/board'
require_relative '../lib/gamestate'
require_relative '../lib/check'
require_relative '../lib/valid_moves'
require_relative '../lib/figures'
require_relative '../lib/king'
require_relative '../lib/rook'
require_relative '../lib/bishop'

class GameStateTester
  include Game_states
  attr_accessor :selected_tile
end

describe 'Castling' do
  let(:board) { Board.new }
  let(:game) { GameStateTester.new }
  let(:white_king) { King_white.new }
  let(:black_king) { King_black.new }
  let(:rook_w_ks) { Rook_white.new } 
  let(:rook_w_qs) { Rook_white.new } 
  let(:rook_b_ks) { Rook_black.new } 
  let(:rook_b_qs) { Rook_black.new } 

  before do
    Valid_moves.build_targets
    board.grid.each { |row| row.each { |tile| tile.figure = nil } }
    

    board.add_figure(white_king, [0, 4])
    board.add_figure(rook_w_ks, [0, 7])
    board.add_figure(rook_w_qs, [0, 0])
    
    board.add_figure(black_king, [7, 4])
    board.add_figure(rook_b_ks, [7, 7])
    board.add_figure(rook_b_qs, [7, 0])
  end

  context 'white castling' do
    let(:white_king_tile) { board.grid[0][4] }

    it 'allows kingside castling' do
      game.selected_tile = white_king_tile
      destination_tile = board.grid[0][6]
      game.select_target_tile_white(destination_tile, board)
      

      expect(board.grid[0][6].figure).to eq(white_king)
      expect(board.grid[0][5].figure).to eq(rook_w_ks)
    end

    it 'allows queenside castling' do
      game.selected_tile = white_king_tile
      destination_tile = board.grid[0][2]
      game.select_target_tile_white(destination_tile, board)

      expect(board.grid[0][2].figure).to eq(white_king)
      expect(board.grid[0][3].figure).to eq(rook_w_qs)
    end

    it 'disallows castling if king has moved' do
      white_king.first_move = false 
      game.selected_tile = white_king_tile
      destination_tile = board.grid[0][6]
      game.select_target_tile_white(destination_tile, board)

    
      expect(board.grid[0][4].figure).to eq(white_king)
    end

    it 'disallows castling if path is blocked' do
      board.add_figure(Bishop_white.new, [0, 5])
      game.selected_tile = white_king_tile
      destination_tile = board.grid[0][6]
      game.select_target_tile_white(destination_tile, board)

      expect(board.grid[0][4].figure).to eq(white_king)
    end

    it 'disallows castling if king would pass through check' do
      board.add_figure(Rook_black.new, [2, 5]) 
      game.selected_tile = white_king_tile
      destination_tile = board.grid[0][6]
      game.select_target_tile_white(destination_tile, board)

      expect(board.grid[0][4].figure).to eq(white_king)
    end
  end
  

end