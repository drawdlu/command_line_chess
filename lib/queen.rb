require_relative 'piece'

class Queen < Piece
  def valid_move?(position)
    (diagonal?(position) || vertical_horizontal?(position)) &&
      no_pieces_on_path?(position) &&
      empty_or_opponent?(position)
  end

  def to_s
    color == :white ? '♛ ' : '♕ '
  end

  def all_valid_moves
    directional_moves(DIAGONAL) + directional_moves(HORIZONTAL_VERTICAL)
  end
end
