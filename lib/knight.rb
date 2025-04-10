require_relative 'piece'

class Knight < Piece
  def move(position)
    return false unless valid_move?(position)

    @current_position = position

    true
  end

  def valid_move?(position)
    x_distance = (@current_position[0].ord - position[0].ord).abs
    y_distance = (@current_position[1].ord - position[1].ord).abs

    valid_distances = [[1, 2], [2, 1]]

    valid_distances.include?([x_distance, y_distance]) &&
      (@board.empty?(position) ||
      opponent?(position))
  end
end
