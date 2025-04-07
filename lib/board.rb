# frozen_string_literal: true

require_relative '../lib/positions'

# Handles state of board
class Board
  include Positions

  attr_reader :board

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
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

  def print_row(row, y_index)
    print_space
    row.each_with_index do |val, x_index|
      print '| '
      print square_name(x_index, y_index) if val.nil?
      print ' '
    end
    print '|'
    puts
  end

  def print_line
    print_space
    puts '-----------------------------------------'
  end

  def print_space
    print '                '
  end
end
