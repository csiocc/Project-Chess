require_relative "board"
require_relative "tile"
require_relative "../config"



class DisplayLogger
  def initialize(display_bot)
    @display = display_bot
    @original_stdout = STDOUT
  end

  def write(message)
    clean_message = message.gsub("\u0000", "")
    clean_message = clean_message.gsub("\x00", "")
    @original_stdout.write(message)
    @display&.log(clean_message.to_s)
  end

  def flush
    @original_stdout.flush
  end
end

class DisplayBotTile < Tile
  def initialize(...)
    @messages = []
    @text_objects = []
    @max_lines = 10
  end
    
  def log(message)
    @messages << message.to_s.chomp
    @messages.shift if @messages.size > @max_lines
    redraw
  end

  private

  def redraw
    @text_objects.each(&:remove)
    @text_objects.clear

    @messages.each_with_index do |msg, i|
     display_msg = i == @messages.size - 2 ? "#{msg + "<-"}" : "#{msg}"
      @text_objects << Text.new(
        display_msg,
        x: @draw_cords[:x] + Config.border,
        y: @draw_cords[:y] + Config.border + i * (Config.border * 5),
        size: Config.console_text_size,
        color: "black"
      )
    end
  end
  
end