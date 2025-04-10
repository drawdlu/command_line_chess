# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'
require_relative 'board'

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
