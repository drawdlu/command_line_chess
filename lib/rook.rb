# frozen_string_literal: true

require_relative 'piece'

# Controls rook movements
class Rook < Piece
  def to_s
    color == :white ? '♜ ' : '♖ '
  end

  def all_valid_moves
    directional_moves(HORIZONTAL_VERTICAL)
  end
end
