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

  attr_reader :board

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
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
    position = color == :white ? 'A2' : 'A7'

    BOARD_SIZE.times do |num|
      line.push(Pawn.new(color, position, self))
      if num < BOARD_SIZE - 1 # rubocop:disable Style/IfUnlessModifier
        position = LETTER_POSITIONS[(position[0].ord + 1) - 'A'.ord] + position[1]
      end
    end

    line
  end

  def major_minor_pieces(color)
    row_num = color == :white ? '1' : '8'
    pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    line = []

    pieces.each_with_index do |piece, index|
      position = LETTER_POSITIONS[index] + row_num
      line.push(piece.new(color, position, self))
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
