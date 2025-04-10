# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'
require_relative 'board'

# Controls rook movements
class Rook < Piece
  def move(position)
    return false unless horizontal_or_vertical_move?(position) &&
                        no_pieces_on_path?(position) &&
                        (@board.empty?(position) || opponent?(position))

    @current_position = position

    true
  end

  def horizontal_or_vertical_move?(position)
    @current_position[0] == position[0] || @current_position[1] == position[1]
  end

  def no_pieces_on_path?(position)
    if @current_position[0] == position[0]
      x_direction = 0
      y_direction = get_direction(@current_position[1], position[1])
    else
      x_direction = get_direction(@current_position[0], position[0])
      y_direction = 0
    end

    no_pieces_in_direction?(position, x_direction, y_direction)
  end
end
