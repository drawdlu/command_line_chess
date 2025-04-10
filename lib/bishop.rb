# frozen_string_literal: true

require_relative 'piece'

# Controls bishop movement
class Bishop < Piece
  def move(position)
    return false unless valid_move?(position)

    @current_position = position

    true
  end

  def valid_move?(position)
    x_direction = get_direction(@current_position[0], position[0])
    y_direction = get_direction(@current_position[1], position[1])

    @current_position[0] != position[0] &&
      @current_position[1] != position[1] &&
      same_distance?(position) &&
      no_pieces_in_direction?(position, x_direction, y_direction) &&
      (@board.empty?(position) ||
      opponent?(position))
  end

  def same_distance?(position)
    x_distance = (@current_position[0].ord - position[0].ord).abs
    y_distance = (@current_position[1].ord - position[1].ord).abs

    x_distance == y_distance
  end
end
