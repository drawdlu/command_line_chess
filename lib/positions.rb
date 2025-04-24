# frozen_string_literal: true

# converting position names and index
module Positions
  LETTER_POSITIONS = %w[A B C D E F G H].freeze
  BOARD_SIZE = 8

  def get_name_index(position)
    letter = position[0]
    number = position[1]

    y_index = letter.ord - 'A'.ord
    x_index = 8 - number.to_i
    { y: y_index, x: x_index }
  end

  def square_name(x_index, y_index)
    LETTER_POSITIONS[y_index] + (8 - x_index).to_s
  end

  def get_piece(position, board = self)
    return nil if board.empty?(position)

    index = get_name_index(position)
    board.board[index[:x]][index[:y]]
  end

  def move_pos(position, x_direction, y_direction)
    index = get_name_index(position)
    x_index = index[:x] + x_direction
    y_index = index[:y] + y_direction

    square_name(x_index, y_index)
  end

  # range is 0-7 min max index of board
  def within_range?(index)
    index < BOARD_SIZE && index >= 0
  end

  def valid_position?(position)
    square_name_length = 2
    valid_positions = /[A-Ha-h][1-8]/
    valid_positions.match?(position) && position.length == square_name_length
  end

  # a Letter moves along the axis of its index
  # a Number moves opposite the axis of its index
  def get_direction(current_pos, move_to_pos)
    return 0 if current_pos == move_to_pos

    letter = /[A-H]/
    if letter.match(current_pos)
      current_pos < move_to_pos ? 1 : -1
    else
      current_pos < move_to_pos ? -1 : 1
    end
  end

  def within_board?(position, x_direction, y_direction)
    index = get_name_index(position)

    x_index = index[:x] + x_direction
    y_index = index[:y] + y_direction

    within_range?(x_index) && within_range?(y_index)
  end
end
