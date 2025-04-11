require_relative 'piece'

class Knight < Piece
  def valid_move?(position)
    valid_distance?(position) && empty_or_opponent?(position)
  end

  def to_s
    color == :white ? '♞ ' : '♘ '
  end

  private

  def valid_distance?(position)
    x_distance = get_distance(@current_position[0], position[0])
    y_distance = get_distance(@current_position[1], position[1])

    valid_distances = [[1, 2], [2, 1]]

    valid_distances.include?([x_distance, y_distance])
  end
end
