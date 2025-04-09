# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'

# Controls rook movements
class Rook < Piece
  def horizontal_or_vertical_move?(position)
    @current_position[0] == position[0] || @current_position[1] == position[1]
  end
end
