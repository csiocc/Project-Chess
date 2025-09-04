### tiles on the board ###
require_relative "config"
require "ruby2d"

class Tile
  DEBUG = true
  attr_accessor :cords, :draw_cords, :figure, :en_passant_clone, :text, :text_object, :rectangle

  def initialize
    @cords = nil
    @draw_cords = { x: 0, y: 0, widht: nil, height: nil}
    @figure = nil
    @en_passant_clone = false
    @text = nil
    @text_object = nil
    @rectangle = nil
  end

  def setup_figure(figure) 
    @figure = figure
  end

  def empty?
    @figure == nil
  end

  def add
    @rectangle = Rectangle.new(x: @draw_cords[:x], y: @draw_cords[:y], height: @draw_cords[:height], width: @draw_cords[:width], color: 'white')
    update_text(@text)
  end

  def update_text(new_text)
    @text_object.remove if @text_object
    @text = new_text
    if @text
      @text_object = Text.new(
        @text,
        size: Config.text_size,
        color: 'black',
      )
      text_cords = text_center_cords(@rectangle, @text_object.width, @text_object.height)
      @text_object.x = text_cords[:x]
      @text_object.y = text_cords[:y]
      p "updated button text to: #{new_text}" if DEBUG
    end
  end

  # Helpermethods#
  
  private

  def text_center_cords(rectangle, text_width, text_height)
    return {x: 0, y: 0} unless rectangle
    rect_x = rectangle.x
    rect_y = rectangle.y
    rect_w = rectangle.width
    rect_h = rectangle.height

    center_x = rect_x + rect_w / 2.0
    center_y = rect_y + rect_h / 2.0

    text_x = center_x - text_width / 2.0
    text_y = center_y - text_height / 2.0

    { x: text_x, y: text_y }
  end
end