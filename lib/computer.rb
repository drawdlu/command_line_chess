require_relative 'board'
require_relative 'game'
require_relative 'notation'

# handles computer choosing a move
class Computer
  include Notation

  def initialize(board, game)
    @color = :black
    @board = board
    @game = game
  end

  def pick_random_move
    pieces = @board.black_pieces.to_a.shuffle
    move = nil
    piece = nil
    notation = nil

    pieces.each do |black_piece|
      black_piece.valid_moves.to_a.shuffle.each do |position|
        piece = black_piece
        move = position
        notation = convert_to_notation(piece, move)
        break if @game.valid_move?(notation)
      end
      break unless move.nil?
    end

    notation
  end

  def convert_to_notation(piece, move)
    notation = move.downcase.split('')
    takes = @board.empty?(move) ? '' : 'x'
    piece_class = get_class(piece)
    notation.unshift(takes)
    notation.unshift(piece_class)

    notation.join
  end

  def get_class(piece)
    piece_class = piece.class
    Game::MOVES.each_key do |key|
      return key.to_s if Game::MOVES[key] == piece_class
    end

    ''
  end
end
