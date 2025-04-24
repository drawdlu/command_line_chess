# frozen_string_literal: true

require_relative 'piece'

# Controls bishop movement
class Bishop < Piece
  def to_s
    '♝'
  end

  def all_valid_moves
    directional_moves(DIAGONAL)
  end
end
