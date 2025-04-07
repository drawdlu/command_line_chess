# frozen_string_literal: true

# Handles state of board
class Board
  LETTER_POSITIONS = %w[A B C D E F G H].freeze

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

  def square_name(x_index, y_index)
    LETTER_POSITIONS[x_index] + (8 - y_index).to_s
  end
end
