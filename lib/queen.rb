require_relative 'piece'

class Queen < Piece
  def to_s
    color == :white ? '♛ ' : '♕ '
  end

  def all_valid_moves
    directional_moves(DIAGONAL) + directional_moves(HORIZONTAL_VERTICAL)
  end
end
