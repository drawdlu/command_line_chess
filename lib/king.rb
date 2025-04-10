require_relative 'piece'

class King < Piece
  def valid_move?(position)
    one_square_distance?(position) &&
      (@board.empty?(position) || opponent?(position))
  end

  def one_square_distance?(position)
    x_distance = (@current_position[0].ord - position[0].ord).abs
    y_distance = (@current_position[1].ord - position[1].ord).abs

    x_distance <= 1 && y_distance <= 1
  end

  def to_s
    color == :white ? '♚ ' : '♔ '
  end
end
