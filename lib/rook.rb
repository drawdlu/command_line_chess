# frozen_string_literal: true

require_relative 'piece'

# Controls rook movements
class Rook < Piece
  def valid_move?(position)
    vertical_horizontal?(position) &&
      no_pieces_on_path?(position) &&
      empty_or_opponent?(position)
  end

  def to_s
    color == :white ? '♜ ' : '♖ '
  end

  def all_valid_moves
    directional_moves(HORIZONTAL_VERTICAL)
  end
end
