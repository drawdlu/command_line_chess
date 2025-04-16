require_relative 'piece'
require_relative 'positions'

class King < Piece
  KING_MOVES = [1, -1, 0].repeated_permutation(2).to_set.delete([0, 0])
  WHITE_ROOKS = %w[A1 H1]
  BLACK_ROOKS = %w[A8 H8]

  include Positions

  attr_reader :moved

  def initialize(color, current_position, board)
    super
    @moved = false
  end

  def to_s
    color == :white ? '♚ ' : '♔ '
  end

  def all_valid_moves
    possible_moves(KING_MOVES)
  end

  def update_position(position)
    @current_position = position
    @moved = true
  end

  private

  def one_square_distance?(position)
    x_distance = get_distance(@current_position[0], position[0])
    y_distance = get_distance(@current_position[1], position[1])

    x_distance <= 1 && y_distance <= 1
  end

  def castling
    moves = Set[]
    rooks_position = @color == :white ? WHITE_ROOKS : BLACK_ROOKS

    rooks_position.each do |position|
      moves.add(position) if ally_of_class_has_not_moved?(position, Rook) &&
                             valid_castling_move?(position)
    end

    moves
  end
end
