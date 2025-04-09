# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'

# Controls movement and characteristics of a pawn in chess
class Pawn < Piece
  include Positions

  def move(to_position)
    valid_moves.include?(to_position) ? @current_position = to_position : nil
  end

  def valid_moves
    current_index = get_name_index(@current_position)

    # white goes up vertically in the 2d array and black goes the opposite way
    # forward movement along y_index
    direction = @color == :white ? -1 : 1

    forward = get_forward_move(current_index[1], current_index[0], direction)
    diagonal_moves = get_diagonal_moves(current_index[1], current_index[0], direction)
    double = get_double_move(current_index[1], current_index[0], direction)

    forward + diagonal_moves + double
  end

  def get_forward_move(x_index, y_index, direction)
    forward = square_name(x_index, y_index + direction)

    @board.empty?(forward) ? [forward] : []
  end

  def get_diagonal_moves(x_index, y_index, direction)
    diagonal_moves = []
    diagonal_moves.push(square_name(x_index + 1, y_index + direction)) if x_index + 1 < BOARD_SIZE
    diagonal_moves.push(square_name(x_index - 1, y_index + direction)) unless (x_index - 1).negative?

    valid_diagonal_moves = []

    diagonal_moves.each do |move|
      next if @board.empty?(move)

      valid_diagonal_moves << move if opponent?(move)
    end

    valid_diagonal_moves
  end

  def get_double_move(x_index, y_index, direction)
    forward = square_name(x_index, y_index + direction)
    first_position = @color == :white ? 6 : 1

    double = double_move(x_index, y_index, direction, first_position)

    valid_double?(double, forward) ? [double] : []
  end

  def valid_double?(double, forward)
    !double.nil? && @board.empty?(double) && @board.empty?(forward)
  end

  def double_move(x_index, y_index, direction, first_position)
    if first_position == y_index
      return square_name(x_index, y_index + (direction * 2)) if @color == :white

      return square_name(x_index, y_index + (direction * 2))
    end

    nil
  end
end
