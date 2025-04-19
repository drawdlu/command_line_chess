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
    directional_moves(HORIZONTAL_VERTICAL) + castling
  end

  def update_position(position)
    @current_position = position
    @moved = true
  end

  private

  def castling
    moves = Set[]
    king_position = @color == :white ? 'E1' : 'E8'

    moves.add(king_position) if ally_of_class_has_not_moved?(king_position, King) &&
                                valid_castling_move?(king_position)

    moves
  end
end
