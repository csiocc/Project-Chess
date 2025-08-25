require_relative "lib/board"
require_relative "lib/tile"
require "ruby2d"
system 'clear'

test = Board.new
test.setup
test.draw_board

set title: 'Knights Travails press ESC to exit'
set width: 1024
set height: 1024

test.setup_figures

test.grid[1][1].figure.move(test.grid[2][1])

show