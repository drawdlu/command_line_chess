# frozen_string_literal: true

# superclass for chess pieces
class Piece
  def initialize(color, current_position, board)
    @color = color
    @current_position = current_position
    @board = board
  end
end
