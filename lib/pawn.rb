# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'

# Controls movement and characteristics of a pawn in chess
class Pawn < Piece
  include Positions

  def valid_moves
    moves = []
    current_index = get_name_index(@current_position)

    # white goes up vertically in the 2d array and black goes the opposite way
    direction = @color == :white ? -1 : 1

    forward = square_name(current_index[1], current_index[0] + direction)
    moves.push(forward) if @board.empty?(forward)

    diagonal = []
    x_index = current_index[1]
    y_index = current_index[0]
    diagonal.push(square_name(x_index + 1, y_index + direction)) if x_index + 1 < BOARD_SIZE
    diagonal.push(square_name(x_index - 1, y_index + direction)) if (x_index - 1) >= 0

    diagonal.each do |move|
      moves << move unless @board.empty?(move)
    end

    moves
  end
end
