# frozen_string_literal: true

require_relative 'positions'

# superclass for chess pieces
class Piece
  include Positions

  attr_reader :color

  def initialize(color, current_position, board)
    @color = color
    @current_position = current_position
    @board = board
  end

  def opponent?(position)
    index = get_name_index(position)

    @board.board[index[0]][index[1]].color != @color
  end

  def move_pos(position, x_direction, y_direction)
    LETTER_POSITIONS[(position[0].ord - 'A'.ord + x_direction)] +
      (position[1].to_i + y_direction).to_s
  end
end
