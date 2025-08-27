module Config
  @WINDOW_SIZE = 512
  @TILE_SIZE = (@WINDOW_SIZE / 8)
  @ADD_WIDTH = (@WINDOW_SIZE / 4)
  @BORDER = (@ADD_WIDTH / 64)

  #getter methods to access data
  def self.window_size 
    @WINDOW_SIZE
  end

  def self.window_width
    @WINDOW_SIZE + @ADD_WIDTH
  end

  def self.tile_size
    @TILE_SIZE
  end

  def self.border
    @BORDER
  end

  def self.add_width
    @ADD_WIDTH
  end

  def self.storage_tile_size
    (@ADD_WIDTH / 4) - @BORDER
  end

  def self.storage_border_square_size
    (@ADD_WIDTH / 4)
  end


  def self.display_tile_size
    {width: @ADD_WIDTH - (@BORDER * 2), height: (@WINDOW_SIZE / 4) - (@BORDER*2)}
  end

  def self.button_size
    {width: ((display_tile_size[:width] - @BORDER*3) / 2), height: ((display_tile_size[:height] - @BORDER*5) / 4)}
  end


end
