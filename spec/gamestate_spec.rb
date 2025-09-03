require 'rspec'
require_relative '../lib/board'
require_relative '../lib/gamestate'
require_relative '../lib/figures'
require_relative '../lib/king'
require_relative '../lib/queen'
require_relative '../lib/rook'
require_relative '../lib/pawn'
require_relative '../lib/bishop'
require_relative '../lib/knight'
require_relative '../lib/valid_moves'

describe Game_states do
  let(:board) { Board.new }
  let(:white_king) { King_white.new }
  let(:black_king) { King_black.new }

  before do
    board.grid.each { |row| row.each { |tile| tile.figure = nil } }
    board.figures.clear
    board.white_figures.clear
    board.black_figures.clear

    board.add_figure(white_king, [3, 4]) # Place king in a more central position
    board.add_figure(black_king, [7, 4])
    
    Valid_moves.build_targets
  end

  describe '.select_figure_white (when in check)' do
    context 'Szenario 1: König im Schach durch einen schwarzen Turm' do
      let(:black_rook) { Rook_black.new }

      before do
        board.add_figure(black_rook, [3, 0])
      end

      it 'erlaubt die Auswahl des Königs, um dem Schach zu entkommen' do
        check_info = Game_states.check_status("white", board)
        legal_figures = check_info[:legal_moves].map { |move| move[:figure] }.uniq
        clicked_tile = board.grid[3][4]
        result = Game_states.select_figure_white(clicked_tile, board, legal_figures)
        expect(result[:status]).to eq(:select_target_tile_white)
      end

      it 'erlaubt die Auswahl einer Figur, die den Schach blockieren kann' do
        blocking_rook = Rook_white.new
        board.add_figure(blocking_rook, [3, 2])
        
        check_info = Game_states.check_status("white", board)
        legal_figures = check_info[:legal_moves].map { |move| move[:figure] }.uniq

        clicked_tile = board.grid[3][2]
        result = Game_states.select_figure_white(clicked_tile, board, legal_figures)
        expect(result[:status]).to eq(:select_target_tile_white)
      end

      it 'erlaubt die Auswahl einer Figur, die die schachgebende Figur schlagen kann' do
        capturing_rook = Rook_white.new
        board.add_figure(capturing_rook, [5, 0])

        check_info = Game_states.check_status("white", board)
        legal_figures = check_info[:legal_moves].map { |move| move[:figure] }.uniq

        clicked_tile = board.grid[5][0]
        result = Game_states.select_figure_white(clicked_tile, board, legal_figures)
        expect(result[:status]).to eq(:select_target_tile_white)
      end
    end

    context 'Szenario 2: König im Doppelschach' do
      before do
        board.add_figure(Rook_black.new, [3, 0])
        board.add_figure(Bishop_black.new, [1, 2])
        board.add_figure(Rook_white.new, [5, 5])
        
        @check_info = Game_states.check_status("white", board)
        @legal_figures = @check_info[:legal_moves].map { |move| move[:figure] }.uniq
      end

      it 'erlaubt nur die Auswahl des Königs' do
        expect(@legal_figures.length).to eq(1)
        expect(@legal_figures.first).to be_a(King_white)

        clicked_tile = board.grid[3][4]
        result = Game_states.select_figure_white(clicked_tile, board, @legal_figures)
        expect(result[:status]).to eq(:select_target_tile_white)
      end
    end

    context 'Szenario 3: Schach durch Springer' do
      before do
        board.add_figure(Knight_black.new, [1, 3]) # Springer setzt auf d2 Schach
        board.add_figure(Rook_white.new, [1, 4])   # Ein Turm, der nichts tun kann
      end

      it 'erlaubt die Auswahl des Königs' do
        check_info = Game_states.check_status("white", board)
        legal_figures = check_info[:legal_moves].map { |move| move[:figure] }.uniq
        clicked_tile = board.grid[3][4]
        result = Game_states.select_figure_white(clicked_tile, board, legal_figures)
        expect(result[:status]).to eq(:select_target_tile_white)
      end

      it 'erlaubt die Auswahl einer Figur, die den Springer schlagen kann' do
        board.add_figure(Bishop_white.new, [0, 2]) # Läufer kann Springer schlagen
        check_info = Game_states.check_status("white", board)
        legal_figures = check_info[:legal_moves].map { |move| move[:figure] }.uniq

        clicked_tile = board.grid[0][2]
        result = Game_states.select_figure_white(clicked_tile, board, legal_figures)
        expect(result[:status]).to eq(:select_target_tile_white)
      end

      it 'verbietet die Auswahl einer Figur, die nicht helfen kann' do
        board.add_figure(Rook_white.new, [0, 4]) # Turm auf e1, kann nicht helfen
        check_info = Game_states.check_status("white", board)
        legal_figures = check_info[:legal_moves].map { |move| move[:figure] }.uniq

        clicked_tile = board.grid[0][4] # Klick auf den nutzlosen Turm
        result = Game_states.select_figure_white(clicked_tile, board, legal_figures)
        expect(result[:status]).to eq(:check_white)
      end
    end

    context 'Szenario 4: Schachmatt' do
      it 'gibt den Status :check_mate_white zurück' do
        # Setup für ein einfaches Back-Rank-Mate
        board.figures.clear; board.white_figures.clear; board.black_figures.clear
        board.add_figure(white_king, [0, 7]) # König auf h1
        board.add_figure(Pawn_white.new, [1, 6]) # Bauer auf g2
        board.add_figure(Pawn_white.new, [1, 7]) # Bauer auf h2
        board.add_figure(Rook_black.new, [0, 0]) # Turm auf a1 setzt matt

        check_info = Game_states.check_status("white", board)
        expect(check_info[:status]).to eq(:check_mate_white)
        expect(check_info[:legal_moves]).to be_empty
      end
    end
  end

  describe 'Bauern-Spezialfälle' do
    context 'wenn ein Bauer seinen ersten Zug macht' do
      let(:white_pawn) { Pawn_white.new }
      before do
        board.figures.clear; board.white_figures.clear; board.black_figures.clear
        white_pawn.first_move = true
      end

      it 'kann nicht auf ein Feld ziehen, das vom gegnerischen König besetzt ist' do
        board.add_figure(white_pawn, [1, 4]) # Bauer auf e2
        board.add_figure(black_king, [3, 4]) # Schwarzer König auf e4
        
        Game_states.instance_variable_set(:@selected_tile, board.grid[1][4])
        clicked_tile = board.grid[3][4]
        result = Game_states.select_target_tile_white(clicked_tile, board)

        expect(result[:status]).to eq(:select_target_tile_white)
        expect(board.grid[3][4].figure).to be_a(King_black)
      end

      it 'kann keine Figur überspringen, die direkt vor ihm steht' do
        board.add_figure(white_pawn, [1, 4]) # Bauer auf e2
        board.add_figure(black_king, [2, 4]) # Schwarzer König auf e3

        Game_states.instance_variable_set(:@selected_tile, board.grid[1][4])
        clicked_tile = board.grid[3][4]
        result = Game_states.select_target_tile_white(clicked_tile, board)

        expect(result[:status]).to eq(:select_target_tile_white)
        expect(board.grid[2][4].figure).to be_a(King_black)
      end

      it 'verursacht ein Schach, wenn eine Figur einen Angriff aufdeckt (Discovered Check)' do
        # Setup: Weißer Turm d1, weißer Bauer d2, schwarzer Springer c3, schwarzer König d8
        board.figures.clear; board.white_figures.clear; board.black_figures.clear
        board.add_figure(white_king, [0, 7])      # Weißer König aus dem Weg
        board.add_figure(Rook_white.new, [0, 3])  # Turm auf d1
        pawn = Pawn_white.new
        board.add_figure(pawn, [1, 3])           # Bauer auf d2
        board.add_figure(Knight_black.new, [2, 2]) # Schwarzer Springer auf c3
        board.add_figure(black_king, [7, 3])     # König auf d8
        
        # Bauernzug d2xc3 deckt Angriff auf d-Linie auf
        Game_states.instance_variable_set(:@selected_tile, board.grid[1][3])
        clicked_tile = board.grid[2][2]
        result = Game_states.select_target_tile_white(clicked_tile, board)

        # Das Ergebnis sollte ein Schach für Schwarz sein
        expect(result[:status]).to eq(:check_black)
      end
    end
  end
end