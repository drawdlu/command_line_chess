require_relative 'board'
require_relative 'game'
require_relative 'notation'

# handles computer choosing a move
class Computer
  include Notation

  attr_reader :name, :color

  def initialize(game, color)
    @name = color.to_s
    @color = color
    @game = game
  end

  def pick_random_move
    pieces = color == :black ? @game.board.black_pieces.to_a.shuffle : @game.board.white_pieces.to_a.shuffle
    move = nil
    piece = nil
    notation = nil

    pieces.each do |black_piece|
      black_piece.valid_moves.to_a.shuffle.each do |position|
        piece = black_piece
        move = position
        notation = convert_to_notation(piece, move)
        return notation if @game.valid_move?(notation)
      end
    end
  end

  def convert_to_notation(piece, move)
    notation = move.downcase.split('')
    takes = @game.board.empty?(move) ? '' : 'x'
    piece_class = get_class(piece, move)
    notation.unshift(takes)
    notation.unshift(piece_class)

    notation.join
  end

  def get_class(piece, move)
    piece_class = piece.class
    Game::MOVES.each_key do |key|
      return key.to_s if Game::MOVES[key] == piece_class
    end

    @game.board.empty?(move) ? '' : piece.current_position[0].downcase
  end
end
