# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'

# Controls movement and characteristics of a pawn in chess
class Pawn < Piece
  include Positions

  def valid_move?(position)
    all_valid_moves.include?(position)
  end

  def to_s
    color == :white ? '♟ ' : '♙ '
  end

  def all_valid_moves
    # white goes up vertically in the 2d array and black goes the opposite way
    # forward movement along y_index
    direction = @color == :white ? -1 : 1
    current_index = get_name_index(@current_position)

    forward = get_forward_move(current_index[:x], current_index[:y], direction)
    diagonal_moves = get_diagonal_moves(current_index[:x], current_index[:y], direction)
    double = get_double_move(current_index[:x], current_index[:y], direction)

    (forward + diagonal_moves + double).to_set
  end

  private

  def get_forward_move(x_index, y_index, direction)
    forward = square_name(x_index + direction, y_index)

    @board.empty?(forward) ? Set[forward] : Set[]
  end

  def get_diagonal_moves(x_index, y_index, direction)
    diagonal_moves = Set[]
    diagonal_moves.add(square_name(x_index + direction, y_index + 1)) unless (y_index + 1) == BOARD_SIZE
    diagonal_moves.add(square_name(x_index + direction, y_index - 1)) unless (y_index - 1).negative?
    valid_diagonal_moves = Set[]

    diagonal_moves.each do |move|
      next if @board.empty?(move)

      valid_diagonal_moves << move if opponent?(move)
    end
    valid_diagonal_moves
  end

  def get_double_move(x_index, y_index, direction)
    forward = square_name(x_index + direction, y_index)
    first_position = @color == :white ? 6 : 1

    double = double_move(x_index, y_index, direction, first_position)

    valid_double?(double, forward) ? Set[double] : Set[]
  end

  def valid_double?(double, forward)
    !double.nil? && @board.empty?(double) && @board.empty?(forward)
  end

  def double_move(x_index, y_index, direction, first_position)
    return square_name(x_index + (direction * 2), y_index) if first_position == x_index

    nil
  end
end
