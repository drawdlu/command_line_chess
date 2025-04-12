require_relative 'piece'

class King < Piece
  KING_MOVES = [1, -1, 0].repeated_permutation(2).to_set.delete([0, 0])

  def valid_move?(position)
    one_square_distance?(position) && empty_or_opponent?(position)
  end

  def to_s
    color == :white ? '♚ ' : '♔ '
  end

  def all_valid_moves
    possible_moves(KING_MOVES)
  end

  private

  def one_square_distance?(position)
    x_distance = get_distance(@current_position[0], position[0])
    y_distance = get_distance(@current_position[1], position[1])

    x_distance <= 1 && y_distance <= 1
  end
end
