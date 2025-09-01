require 'rspec'
require_relative '../lib/board'
require_relative '../lib/gamestate'
require_relative '../lib/check'
require_relative '../lib/valid_moves'
require_relative '../lib/figures'
require_relative '../lib/pawn'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'


describe 'Pawn Promotion' do
  let(:board) { Board.new }


  before do
    Valid_moves.build_targets
    board.grid.each { |row| row.each { |tile| tile.figure = nil } }
    Game_states.instance_variable_set(:@selected_tile, nil)
    Game_states.instance_variable_set(:@pawn_to_promote, nil)
  end

  context 'when a white pawn reaches the last rank' do
    let(:white_pawn) { Pawn_white.new }
    let(:pawn_start_tile) { board.grid[6][4] }
    let(:pawn_dest_tile) { board.grid[7][4] } 

    before do
      board.add_figure(King_white.new, [0, 4])
      board.add_figure(King_black.new, [5, 4])
      board.add_figure(white_pawn, [6, 4])
      white_pawn.first_move = false
      Game_states.instance_variable_set(:@selected_tile, pawn_start_tile)
    end

    it 'promotes to a Queen successfully' do
      board.add_figure(Queen_white.new, [0, 0])
      choice_tile = board.grid[0][0]

      result = Game_states.select_target_tile_white(pawn_dest_tile, board)
      expect(result[:status]).to eq(:promote_pawn)

      Game_states.handle_promotion(choice_tile, board)

      promoted_piece = board.grid[7][4].figure
      expect(promoted_piece).to be_an_instance_of(Queen_white)
    end

    it 'does not promote if a black piece is chosen' do
      board.add_figure(Queen_black.new, [0, 0])
      choice_tile = board.grid[0][0]

      result = Game_states.select_target_tile_white(pawn_dest_tile, board)
      final_state = Game_states.handle_promotion(choice_tile, board)

      expect(final_state[:status]).to eq(:error)
      expect(board.grid[7][4].figure).to be_an_instance_of(Pawn_white)
    end

    it 'does not promote if a King is chosen' do
      board.add_figure(King_white.new, [0, 0])
      choice_tile = board.grid[0][0]

      result = Game_states.select_target_tile_white(pawn_dest_tile, board)
      final_state = Game_states.handle_promotion(choice_tile, board)

      expect(final_state[:status]).to eq(:promote_pawn)
    end

    it 'results in check if the new piece attacks the king' do
      board.add_figure(King_black.new, [5, 4])
      board.add_figure(Queen_white.new, [0, 0])
      choice_tile = board.grid[0][0]

      Game_states.select_target_tile_white(pawn_dest_tile, board)
      final_state = Game_states.handle_promotion(choice_tile, board)

      expect(final_state).to eq(:check_black)
    end
  end

  context 'when a black pawn reaches the first rank' do
    let(:black_pawn) { Pawn_black.new }
    let(:pawn_start_tile) { board.grid[1][3] } 
    let(:pawn_dest_tile) { board.grid[0][3] } 

    before do
      board.add_figure(King_white.new, [5, 0])
      board.add_figure(King_black.new, [7, 4])
      board.add_figure(black_pawn, [1, 3])
      black_pawn.first_move = false
      Game_states.instance_variable_set(:@selected_tile, pawn_start_tile)
    end

    it 'promotes to a Rook successfully' do
      board.add_figure(Rook_black.new, [7, 7])
      choice_tile = board.grid[7][7]

      result = Game_states.select_target_tile_black(pawn_dest_tile, board)
      expect(result[:status]).to eq(:promote_pawn)

      Game_states.handle_promotion(choice_tile, board)

      promoted_piece = board.grid[0][3].figure
      expect(promoted_piece).to be_an_instance_of(Rook_black)
    end
  end
end