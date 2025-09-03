
require_relative "tile"
require_relative "pawn"
require_relative "rook"
require_relative "knight"
require_relative "bishop"
require_relative "queen"
require_relative "king"
require_relative "config"
require_relative "valid_moves"
require_relative "display_logger"
require "ruby2d"

###Board Class creating the Board and storing Tiles and functions to access them###
class Board
  include Config
  attr_reader  :grid, :tiles, :white_storage, :black_storage, :buttons
  attr_accessor :figures, :white_storage, :black_storage, :white_figures, :black_figures, :save_game_state
  DEBUG = false
  DEBUG2 = false
  def initialize
    @grid = nil
    @tiles = []
    @white_positions = []
    @black_positions = []
    @figures = []
    @white_storage = []
    @black_storage = []
    @display = []
    @buttons = []
    @white_figures = []
    @black_figures = []
    @save_game_state = nil
    setup
    draw_board
  end

  ###Board setup with 8x8 Tiles###
  def setup
    @grid = Array.new(8) { Array.new(8) }
    (0..7).each do |row|
      (0..7).each do |col|
        tile = Tile.new
        tile.cords = [row, col]
        @grid[row][col] = tile
        @tiles << tile
      end
    end
    # set tile draw cords for ruby2d
  
    (0..7).each do |row|
      (0..7).each do |col|
        x = col * Config.tile_size
        y = row * Config.tile_size
        @grid[row][col].draw_cords = { x: x, y: y }
        if (row + col).even?
          @white_positions << { x: x, y: y }
        else
          @black_positions << { x: x, y: y }
        end
      end
    end
    setup_storage
    setup_console_display
    setup_display_buttons
    $stdout = DisplayLogger.new(@display[1])
  end

  def setup_storage
    (0...4).each do |r|
      (0...4).each do |c|
        x = Config.window_size + Config.border + (c * (Config.tile_size / 2))
        y = r * (Config.tile_size / 2) + Config.border
        xb = Config.window_size + (c * (Config.tile_size / 2)) + Config.border
        yb = ((Config.window_size / 4) * 3) + (r * (Config.tile_size / 2)) + Config.border
      tile_white = Tile.new
      tile_black = Tile.new
      tile_white.draw_cords = { x: x, y: y}
      tile_black.draw_cords = { x: xb, y: yb}
      @white_storage << tile_white
      @tiles << tile_white
      @black_storage << tile_black
      @tiles << tile_black
      end
    end  
  end

  def setup_console_display
    display_top_tile = Tile.new
    display_top_tile.draw_cords = { x: Config.window_size + Config.border, y: (Config.window_size / 4) + Config.border }
    @display << display_top_tile
    display_bot_tile = DisplayBotTile.new
    display_bot_tile.draw_cords = { x: Config.window_size + Config.border, y: ((Config.window_size / 4) * 2) + Config.border}
    @display << display_bot_tile
    @tiles << display_top_tile
    @tiles << display_bot_tile
  end

  def setup_display_buttons
    4.times do |row|
      2.times do |col|
        button = Tile.new
        x = @display[0].draw_cords[:x] + (col * (Config.button_size[:width] + Config.border))
        y = @display[0].draw_cords[:y] + (row * (Config.button_size[:height] + Config.border))
        button.draw_cords = {
                              x: x + Config.border,
                              y: y + Config.border,
                              width: Config.button_size[:width],
                              height: Config.button_size[:height]
                            }

        case [row, col]
        when [0, 0]
          button.text = "Start"
        when [0, 1]
          button.text = "Reset"
        when [1, 0]
          button.text = "Save"
        when [1, 1]
          button.text = "Load"
        when [3, 1]
          button.text = "Exit"
        end
        p "Button at row=#{row}, col=#{col} text=#{button.text} cords: #{button.draw_cords}" if DEBUG
        @buttons << button
      end
    end
  end







  def draw_board
    tile_size = Config.tile_size
    border = Config.border
    storage_tile_size = Config.storage_tile_size
    storage_border_suqare_size = Config.storage_border_square_size
    display_tile_size = Config.display_tile_size
    #draw white tiles
    @white_positions.each do |pos|
      Square.new(x: pos[:x], y: pos[:y], size: tile_size, color: 'white')
    end
    #draw black tiles
    @black_positions.each do |pos|
      Square.new(x: pos[:x], y: pos[:y], size: tile_size, color: 'gray')
    end
    #draw white figure storage
    @white_storage.each do |pos|
      Square.new(x: pos.draw_cords[:x]- border, y: pos.draw_cords[:y] - border, size: storage_border_suqare_size, color: 'black')
      Square.new(x: pos.draw_cords[:x ], y: pos.draw_cords[:y], size: storage_tile_size, color: 'white')
    end
    #draw black figure storage
    @black_storage.each do |pos|
      Square.new(x: pos.draw_cords[:x] - border, y: pos.draw_cords[:y] - border, size: storage_border_suqare_size, color: 'white')
      Square.new(x: pos.draw_cords[:x ], y: pos.draw_cords[:y], size: storage_tile_size, color: 'gray')
    end
    # draw disply tiles
      Rectangle.new(x: @display[0].draw_cords[:x], y: @display[0].draw_cords[:y], width: display_tile_size[:width], height: display_tile_size[:height], color: 'gray')
      Rectangle.new(x: @display[1].draw_cords[:x], y: @display[1].draw_cords[:y], width: display_tile_size[:width], height: display_tile_size[:height], color: 'gray')
    # draw display buttons
    @buttons.each do |button|
      button.add
    end
  end

  def setup_figures
    # pawns
    @grid[1].each do |tile|
      pawn = Pawn_white.new
      pawn.setup(tile)
      @figures << pawn
      @white_figures << pawn
    end
    @grid[6].each do |tile|
      pawn = Pawn_black.new
      pawn.setup(tile)
      @figures << pawn
      @black_figures << pawn
    end
  
    # rooks
    rook = Rook_white.new
    rook.setup(@grid[0][0])
    @figures << rook
    @white_figures << rook
    rook = Rook_white.new
    rook.setup(@grid[0][7])
    @white_figures << rook
    @figures << rook
    rook = Rook_black.new
    rook.setup(@grid[7][0])
    @black_figures << rook
    @figures << rook
    rook = Rook_black.new
    rook.setup(@grid[7][7])
    @black_figures << rook
    @figures << rook

    #knights
    knight = Knight_white.new
    knight.setup(@grid[0][1])
    @white_figures << knight
    @figures << knight
    knight = Knight_white.new
    knight.setup(@grid[0][6])
    @white_figures << knight
    @figures << knight
    knight = Knight_black.new
    knight.setup(@grid[7][1])
    @black_figures << knight
    @figures << knight
    knight = Knight_black.new
    knight.setup(@grid[7][6])
    @black_figures << knight
    @figures << knight

    #bishops
    bishop = Bishop_white.new
    bishop.setup(@grid[0][2])
    @white_figures << bishop
    @figures << bishop
    bishop = Bishop_white.new
    bishop.setup(@grid[0][5])
    @figures << bishop
    @white_figures << bishop
    bishop = Bishop_black.new
    bishop.setup(@grid[7][2])
    @black_figures << bishop
    @figures << bishop
    bishop = Bishop_black.new
    bishop.setup(@grid[7][5])
    @black_figures << bishop
    @figures << bishop

    #queens
    queen = Queen_white.new
    queen.setup(@grid[0][3])
    @white_figures << queen
    @figures << queen
    queen = Queen_black.new
    queen.setup(@grid[7][3])
    @black_figures << queen
    @figures << queen

    #kings
    king = King_white.new
    king.setup(@grid[0][4])
    @white_figures << king
    @figures << king
    king = King_black.new
    king.setup(@grid[7][4])
    @black_figures << king
    @figures << king

    #linking figures to tiles
    @figures.each do |figure|
      figure.current_tile.setup_figure(figure)
    end
    
  end

  def find_tile(cords)
    @tiles.find do |tile|
      (tile.draw_cords[:x]...(tile.draw_cords[:x] + Config.tile_size)).cover?(cords[:x]) &&
      (tile.draw_cords[:y]...(tile.draw_cords[:y] + Config.tile_size)).cover?(cords[:y])
    end
  end

  def find_button(cords)
    @buttons.find do |btn|
      width  = btn.draw_cords[:width]  || Config.button_size[:width]
      height = btn.draw_cords[:height] || Config.button_size[:height]

      (btn.draw_cords[:x]...(btn.draw_cords[:x] + width)).cover?(cords[:x]) &&
      (btn.draw_cords[:y]...(btn.draw_cords[:y] + height)).cover?(cords[:y])
    end
  end

  def reset
    @figures.each do |figure|
      figure.sprite.remove
    end
    self.setup_figures
  end

  def en_passant_reset_black
    @grid.each do |row|
      row.each do |tile|
        if tile.en_passant_clone && tile.figure.color == "black" && tile.figure.is_a?(Pawn)
          p "called en_passant_reset_black on #{tile.cords} and deleted #{tile.figure}" if DEBUG
          tile.en_passant_clone = false
          tile.figure = nil
        end
      end
    end
  end

  def en_passant_reset_white
    @grid.each do |row|
      row.each do |tile|
        if tile.en_passant_clone && tile.figure.color == "white" && tile.figure.is_a?(Pawn)
          p "called en_passant_reset_white on #{tile.cords} and deleted #{tile.figure}" if DEBUG
          tile.en_passant_clone = false
          tile.figure = nil
        end
      end
    end
  end

  def white_king_pos
    @figures.each do |figure|
      if figure.is_a?(King_white)
        return figure.current_tile.cords if figure.is_a?(King_white)
      end
    end
  end

  def black_king_pos
    @figures.each do |figure|
      return figure.current_tile.cords if figure.is_a?(King_black)
    end
  end

  def move_simulation(figure, target_cords)
    current_tile = figure.current_tile
    target_tile = self.grid[target_cords[0]][target_cords[1]]
    taken_figure = target_tile.figure

    undo_info = {
      figure: figure,
      from: current_tile,
      to: target_tile,
      taken_figure: taken_figure
    }

    current_tile.figure = nil
    target_tile.figure = figure
    figure.current_tile = target_tile

    if taken_figure
      self.figures.delete(taken_figure)
      if taken_figure.color == "white"
        self.white_figures.delete(taken_figure)
      else
        self.black_figures.delete(taken_figure)
      end
    end

    return undo_info
  end

  def undo_simulation(undo_info)
    figure = undo_info[:figure]
    from_tile = undo_info[:from]
    to_tile = undo_info[:to]
    taken_figure = undo_info[:taken_figure]

    to_tile.figure = taken_figure
    from_tile.figure = figure
    figure.current_tile = from_tile

    if taken_figure
      self.figures << taken_figure
      if taken_figure.color == "white"
        self.white_figures << taken_figure
      else
        self.black_figures << taken_figure
      end
    end
  end

  def promote_pawn(pawn, choice_class)
    tile = pawn.current_tile
    color = pawn.color
    #remove pawn
    self.figures.delete(pawn)
    if color == "white"
      self.white_figures.delete(pawn)
    else
      self.black_figures.delete(pawn)
    end
    pawn.sprite.remove
    #create new figure
    new_figure = choice_class.new
    tile.figure = new_figure
    new_figure.current_tile = tile
    @figures << new_figure
    if color == "white"
      @white_figures << new_figure
    else
      @black_figures << new_figure
    end
    new_figure.setup(tile)
  end

  def add_button(value)
    tile = first_free(@buttons)
    tile.display_value = value
  end

  # Helpermethods #
  
  def first_free(array)
    array.each do |tile|
      if tile.empty?
        return tile
      end
    end
  end

  def add_figure(figure, cords)
    tile = @grid[cords[0]][cords[1]]
    tile.figure = figure
    figure.current_tile = tile
    @figures << figure
    if figure.color == "white"
      @white_figures << figure
    else
      @black_figures << figure
    end
  end

  def move_figure(from_cords, to_cords)
    from_tile = @grid[from_cords[0]][from_cords[1]]
    to_tile = @grid[to_cords[0]][to_cords[1]]
    figure = from_tile.figure

    return unless figure #do nothing if there is no figure to move
    
    from_tile.figure = nil
    to_tile.figure = figure
    figure.current_tile = to_tile
  end

  def save_value
    { game_state: @save_game_state, 
      figures: @figures.map { |f|
        cords = f.current_tile.cords
        p "cords loaded: #{cords}"
        h = { type: f.class.name, cords: cords  }
        h[:first_move]  = f.first_move  if f.respond_to?(:first_move)
        h[:en_passant]  = f.en_passant  if f.respond_to?(:en_passant)
        h
      }
    }
  end

  def to_json(*_args)
    JSON.pretty_generate(save_value)
  end

  def self.from_json(json_string)
    data = JSON.parse(json_string, symbolize_names: true)
    raise ArgumentError, "invalid save format" unless data.is_a?(Hash) && data[:figures].is_a?(Array)

    board = Board.new
    data[:figures].each do |f|
      type = f[:type] || f["type"]
      cords = f[:cords]
      klass = Object.const_get(type)
      fig   = klass.new
      tile = board.grid[cords[0]][cords[1]]

      fig.current_tile = tile
      tile.setup_figure(fig)
      fig.first_move = f[:first_move] if f.key?(:first_move) && fig.respond_to?(:first_move=)
      fig.en_passant = f[:en_passant] if f.key?(:en_passant) && fig.respond_to?(:en_passant=)
      fig.setup(tile) # setup sprites to draw figures
      #update collections 
      board.figures << fig
      if fig.color == "white"
        board.white_figures << fig
      else
        board.black_figures << fig
      end
    end
    @save_game_state = data[:game_state].to_sym
    [board, data[:game_state]]
  end

end