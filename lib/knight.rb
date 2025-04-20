require_relative 'piece'

class Knight < Piece
  KNIGHT_MOVES = [1, -1, 2, -2].permutation(2).filter { |pair| pair[0].abs != pair[1].abs }

  def to_s
    '♞'
  end

  def all_valid_moves
    possible_moves(KNIGHT_MOVES)
  end

  private

  def valid_distance?(position)
    x_distance = get_distance(@current_position[0], position[0])
    y_distance = get_distance(@current_position[1], position[1])

    valid_distances = [[1, 2], [2, 1]]

    valid_distances.include?([x_distance, y_distance])
  end
end
