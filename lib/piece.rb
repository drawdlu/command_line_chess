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

  def get_direction(current_pos, move_to_pos)
    return 0 if current_pos == move_to_pos

    current_pos < move_to_pos ? 1 : -1
  end

  def no_pieces_on_path?(position)
    x_direction = get_direction(@current_position[0], position[0])
    y_direction = get_direction(@current_position[1], position[1])

    cur_position_copy = move_pos(@current_position, x_direction, y_direction)

    until cur_position_copy == position
      return false unless @board.empty?(cur_position_copy)

      cur_position_copy = move_pos(cur_position_copy, x_direction, y_direction)
    end

    true
  end

  def diagonal?(position)
    x_distance = (@current_position[0].ord - position[0].ord).abs
    y_distance = (@current_position[1].ord - position[1].ord).abs

    x_distance == y_distance
  end

  def vertical_horizontal?(position)
    @current_position[0] == position[0] || @current_position[1] == position[1]
  end

  def move(position)
    return false unless valid_move?(position)

    @current_position = position

    true
  end

  def empty_or_opponent?(position)
    @board.empty?(position) || opponent?(position)
  end
end
