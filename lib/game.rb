# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/positions'

# Controls game loop and special conditions
class Game
  include Positions

  def initialize
    @board = Board.new
  end

  private

  def get_start_position
    move = ''
    while move == ''
      print 'Pick a piece to move: '
      move = gets.chomp

      return move.upcase if valid_position?(move) &&
                            !@board.empty?(move) &&
                            ally?(move)

      move = ''
    end
  end

  def get_move_position(piece)
    move = ''
    while move == ''
      print 'Pick a square to move to: '
      move = gets.chomp

      return move.upcase if valid_position?(move) && piece.valid_move?(move)

      move = ''
    end
  end

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

test = Game.new

test.get_start_position
