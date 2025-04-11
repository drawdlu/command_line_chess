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
    @board.each_with_index do |row, x_index|
      print_line
      print_row(row, x_index)
    end
    print_line
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

    pieces.each_with_index do |_class, index|
      position = LETTER_POSITIONS[index] + row_num
      piece = _class.new(color, position, self)
      color == :white ? white_pieces.push(piece) : black_pieces.push(piece)
      line.push(piece)
    end

    line
  end

  def print_row(row, y_index)
    print_space
    row.each_with_index do |val, x_index|
      print '|  '
      if val.nil?
        print square_name(x_index, y_index)
      else
        print val
      end
      print ' '
    end
    print '|'
    puts
  end

  def print_line
    print_space
    puts '-------------------------------------------------'
  end

  def print_space
    print '                '
  end
end

test = Board.new

puts test
