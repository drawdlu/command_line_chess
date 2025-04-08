# frozen_string_literal: true

# superclass for chess pieces
class Piece
  attr_reader :color

  def initialize(color, current_position, board)
    @color = color
    @current_position = current_position
    @board = board
  end

  def ally?(position)
    index = get_name_index(position)

    @board.board[index[0]][index[1]].color == @color
  end
end
