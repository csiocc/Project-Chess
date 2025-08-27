### tiles on the board ###
require_relative "config"
require "ruby2d"

class Tile
  DEBUG = true
  attr_accessor :cords, :draw_cords, :figure, :en_passant_clone

  def initialize
    @cords = nil
    @draw_cords = { x: 0, y: 0 }
    @figure = nil
    @en_passant_clone = false
    @display_value = nil
  end

  def setup_figure(figure) 
    @figure = figure
  end

  def empty?
    @figure == nil
  end

  def add
    p "button add called with, width:#{Config.button_size[:width]} and height: #{Config.button_size[:height]} and border: #{Config.border}" if DEBUG
    Rectangle.new(x: (@draw_cords[:x] + Config.border), y: (@draw_cords[:y] + Config.border), height: Config.button_size[:height], width: Config.button_size[:width], color: 'white')
  end
end