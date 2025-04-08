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
    moves = []
    current_index = get_name_index(@current_position)

    # white goes up vertically in the 2d array and black goes the opposite way
    # forward move
    direction = @color == :white ? -1 : 1
    forward = square_name(current_index[1], current_index[0] + direction)
    moves.push(forward) if @board.empty?(forward)

    diagonal_moves = get_diagonal_moves(current_index[1], current_index[0], direction)

    diagonal_moves.each do |move|
      moves << move unless @board.empty?(move)
    end

    double = get_double_move(current_index[1], current_index[0], direction)
    moves.push(double) if !double.nil? && @board.empty?(double) && @board.empty?(forward)

    moves
  end

  def get_diagonal_moves(x_index, y_index, direction)
    moves = []
    moves.push(square_name(x_index + 1, y_index + direction)) if x_index + 1 < BOARD_SIZE
    moves.push(square_name(x_index - 1, y_index + direction)) unless (x_index - 1).negative?

    moves
  end

  def get_double_move(x_index, y_index, direction)
    first_position = @color == :white ? 6 : 1

    if @color == :white
      first_position == y_index ? square_name(x_index, y_index + direction - 1) : nil
    else
      first_position == y_index ? square_name(x_index, y_index + direction + 1) : nil
    end
  end
end
