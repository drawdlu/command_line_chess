# frozen_string_literal: true

require_relative 'piece'

# Controls bishop movement
class Bishop < Piece
  def valid_move?(position)
    diagonal?(position) &&
      no_pieces_on_path?(position) &&
      (@board.empty?(position) || opponent?(position))
  end
end
