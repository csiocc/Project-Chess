
require_relative "tile"
require_relative "pawn"
require_relative "rook"
require_relative "knight"
require_relative "bishop"
require_relative "queen"
require_relative "king"
require "ruby2d"

###Board Class creating the Board and storing Tiles and functions to access them###
class Board
  attr_reader :figures, :grid

  def initialize
    @grid = nil
    @tiles = []
    @white_positions = []
    @black_positions = []
    @figures = []
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
        x = col * 128
        y = row * 128
        @grid[row][col].draw_cords = { x: x, y: y }
        if (row + col).even?
          @white_positions << { x: x, y: y }
        else
          @black_positions << { x: x, y: y }
        end
      end
    end
  end

  def draw_board
    tile_size = 128
    @white_positions.each do |pos|
      Square.new(x: pos[:x], y: pos[:y], size: tile_size, color: 'white')
    end
    @black_positions.each do |pos|
      Square.new(x: pos[:x], y: pos[:y], size: tile_size, color: 'gray')
    end
  end

  def setup_figures
    # pawns
    @grid[1].each do |tile|
      pawn = Pawn_white.new
      pawn.setup(tile)
      @figures << pawn
    end
    @grid[6].each do |tile|
      pawn = Pawn_black.new
      pawn.setup(tile)
      @figures << pawn
    end
  
    # rooks
    rook = Rook_white.new
    rook.setup(@grid[0][0])
    @figures << rook
    rook = Rook_white.new
    rook.setup(@grid[0][7])
    @figures << rook
    rook = Rook_black.new
    rook.setup(@grid[7][0])
    @figures << rook
    rook = Rook_black.new
    rook.setup(@grid[7][7])
    @figures << rook

    #knights
    knight = Knight_white.new
    knight.setup(@grid[0][1])
    @figures << knight
    knight = Knight_white.new
    knight.setup(@grid[0][6])
    @figures << knight
    knight = Knight_black.new
    knight.setup(@grid[7][1])
    @figures << knight
    knight = Knight_black.new
    knight.setup(@grid[7][6])
    @figures << knight

    #bishops
    bishop = Bishop_white.new
    bishop.setup(@grid[0][2])
    @figures << bishop
    bishop = Bishop_white.new
    bishop.setup(@grid[0][5])
    @figures << bishop
    bishop = Bishop_black.new
    bishop.setup(@grid[7][2])
    @figures << bishop
    bishop = Bishop_black.new
    bishop.setup(@grid[7][5])
    @figures << bishop

    #queens
    queen = Queen_white.new
    queen.setup(@grid[0][3])
    @figures << queen
    queen = Queen_black.new
    queen.setup(@grid[7][3])
    @figures << queen

    #kings
    king = King_white.new
    king.setup(@grid[0][4])
    @figures << king
    king = King_black.new
    king.setup(@grid[7][4])
    @figures << king

    #linking figures to tiles
    @figures.each do |figure|
      figure.current_tile.setup_figure(figure)
    end
    
  end


end