
require_relative "tile"
require_relative "pawn"
require_relative "rook"
require_relative "knight"
require_relative "bishop"
require_relative "queen"
require_relative "king"
require_relative "config"
require "ruby2d"

###Board Class creating the Board and storing Tiles and functions to access them###
class Board
  include Config
  DEBUG = true
  attr_reader :figures, :grid

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
    display_bot_tile = Tile.new
    display_bot_tile.draw_cords = { x: Config.window_size + Config.border, y: ((Config.window_size / 4) * 2) + Config.border}
    @display << display_bot_tile
    @tiles << display_top_tile
    @tiles << display_bot_tile
  end

  def setup_display_buttons
    2.times do |r|
      4.times do |c|
        button = Tile.new
        p " r = #{r} and c = #{c}" if DEBUG
        p " r #{r} * #{Config.button_size[:width]}" if DEBUG
        p " c #{c} * #{Config.button_size[:height]}" if DEBUG
        x = @display[0].draw_cords[:x] + (r * (Config.button_size[:width] + Config.border))
        y = @display[0].draw_cords[:y] + (c * (Config.button_size[:height] + Config.border))
        button.draw_cords = { x: x, y: y }
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
      p "button cords = #{button.draw_cords}" if DEBUG
      button.add
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

  def find_tile(cords)
    @tiles.each do |tile|
      if tile.draw_cords[:x] < cords[:x] && tile.draw_cords[:x] + 128 > cords[:x] && tile.draw_cords[:y] < cords[:y] && tile.draw_cords[:y] + 128 > cords[:y]
        return tile
      end
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

end