# frozen_string_literal: true

require_relative '../lib/board'

# Controls game loop and special conditions
class Game
  def initialize
    @board = Board.new
  end

  private

  def valid_position?(position)
    valid_positions = /[A-Ha-h][1-8]/
    valid_positions.match?(position)
  end

  def ally?(position)
    index = get_name_index(position)

    @board.board[index[:x]][index[:y]].color == @active_player.color
  end

  def remove_piece(piece)
    if piece.color == :white
      @board.white_pieces.delete(piece)
    else
      @board.black_pieces.delete(piece)
    end
  end
end
