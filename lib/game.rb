# frozen_string_literal: true

require_relative '../lib/board'

# Controls game loop and special conditions
class Game
  def initialize
    @board = Board.new
  end

  def valid_position?(position)
    valid_positions = /[A-Ha-h][1-8]/
    valid_positions.match?(position)
  end
end
