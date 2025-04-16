# frozen_string_literal: true

require_relative 'piece'

# Controls rook movements
class Rook < Piece
  attr_reader :moved

  def initialize(color, current_position, board)
    super
    @moved = false
  end

  def to_s
    color == :white ? '♜ ' : '♖ '
  end

  def all_valid_moves
    directional_moves(HORIZONTAL_VERTICAL)
  end

  def update_position(position)
    @current_position = position
    @moved = true
  end
end
