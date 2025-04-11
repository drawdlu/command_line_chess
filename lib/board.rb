# frozen_string_literal: true

require_relative '../lib/positions'
require_relative '../lib/pawn'
require_relative '../lib/rook'
require_relative '../lib/bishop'
require_relative '../lib/knight'
require_relative '../lib/queen'
require_relative '../lib/king'

# Handles state of board
class Board
  include Positions

  attr_reader :board, :black_pieces, :white_pieces

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @black_pieces = []
    @white_pieces = []
    populate_board
  end

  def to_s
    board = ''
    @board.each_with_index do |row, x_index|
      board += line
      board += row(row, x_index)
    end
    board += line

    board
  end

  def empty?(position)
    index = get_name_index(position)
    @board[index[0]][index[1]].nil?
  end

  private

  def populate_board
    @board[0] = major_minor_pieces(:black)
    @board[1] = pawn_line(:black)
    @board[6] = pawn_line(:white)
    @board[7] = major_minor_pieces(:white)
  end

  def pawn_line(color)
    line = []
    number = color == :white ? '2' : '7'

    (0..(BOARD_SIZE - 1)).each do |index|
      position = LETTER_POSITIONS[index] + number
      pawn = Pawn.new(color, position, self)
      color == :white ? white_pieces.push(pawn) : black_pieces.push(pawn)
      line.push(pawn)
    end

    line
  end

  def major_minor_pieces(color)
    row_num = color == :white ? '1' : '8'
    pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    line = []

    pieces.each_with_index do |piece_class, index|
      position = LETTER_POSITIONS[index] + row_num
      piece = piece_class.new(color, position, self)
      color == :white ? white_pieces.push(piece) : black_pieces.push(piece)
      line.push(piece)
    end

    line
  end

  def row(row, y_index)
    row_string = space
    row.each_with_index do |val, x_index|
      row_string += if val.nil?
                      "|  #{square_name(x_index, y_index)} "
                    else
                      "|  #{val} "
                    end
    end

    "#{row_string}|\n"
  end

  def line
    "#{space}-------------------------------------------------\n"
  end

  def space
    '                '
  end
end
