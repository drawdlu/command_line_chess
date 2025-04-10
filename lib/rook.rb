# frozen_string_literal: true

require_relative 'piece'

# Controls rook movements
class Rook < Piece
  def move(position)
    return false unless valid_move?(position)

    @current_position = position

    true
  end

  def valid_move?(position)
    vertical_horizontal?(position) &&
      no_pieces_on_path?(position) &&
      (@board.empty?(position) || opponent?(position))
  end
end
