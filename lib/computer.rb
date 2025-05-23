require_relative 'board'
require_relative 'game'
require_relative 'notation'
require_relative 'pieces/pawn'

# handles computer choosing a move
class Computer
  include Notation

  attr_reader :name, :color

  def initialize(game, color)
    @name = "#{color.to_s.capitalize} Computer"
    @color = color
    @game = game
  end

  def pick_random_move
    pieces = @game.board.get_pieces(@color).to_a.shuffle

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
    partial_position = piece.current_position[0].downcase
    notation.unshift(takes)
    unless piece.instance_of?(Pawn) ||
           notation.include?(partial_position) ||
           piece.instance_of?(King)
      notation.unshift(partial_position)
    end
    notation.unshift(piece_class)

    notation.join
  end

  def get_class(piece, move)
    piece_class = piece.class
    MOVES.each_key do |key|
      return key.to_s if MOVES[key] == piece_class
    end

    @game.board.empty?(move) ? '' : piece.current_position[0].downcase
  end
end
