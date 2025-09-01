### tiles on the board ###
require_relative "config"
require "ruby2d"

class Tile
  DEBUG = false
  attr_accessor :cords, :draw_cords, :figure, :en_passant_clone, :text

  def initialize
    @cords = nil
    @draw_cords = { x: 0, y: 0, widht: nil, height: nil}
    @figure = nil
    @en_passant_clone = false
    @text = nil
  end

  def setup_figure(figure) 
    @figure = figure
  end

  def empty?
    @figure == nil
  end

  def add
    p "button add called with, width:#{Config.button_size[:width]} and height: #{Config.button_size[:height]} and border: #{Config.border}" if DEBUG
    rectangle = Rectangle.new(x: (@draw_cords[:x] + Config.border), y: (@draw_cords[:y] + Config.border), height: Config.button_size[:height], width: Config.button_size[:width], color: 'white')
    self.draw_cords[:height] = Config.button_size[:height]
    self.draw_cords[:width] = Config.button_size[:width]
    if @text
      text = Text.new(@text, size: Config.text_size, color: 'black')
      text_cords = text_center_cords(rectangle, text.width, text.height)
      text.x = text_cords[:x]
      text.y = text_cords[:y]         
    end
  end

  # Helpermethods#
  
  def text_center_cords(rectangle, text_width, text_height)
    rect_x = self.draw_cords[:x]
    rect_y = self.draw_cords[:y]
    rect_w = self.draw_cords[:width]
    rect_h = self.draw_cords[:height]

    # Mittelpunkt vom Rechteck
    center_x = rect_x + rect_w / 2.0
    center_y = rect_y + rect_h / 2.0

    # Text so verschieben, dass er mittig ist
    text_x = center_x - text_width / 2.0
    text_y = center_y - text_height / 2.0

    { x: text_x, y: text_y }
  end
end