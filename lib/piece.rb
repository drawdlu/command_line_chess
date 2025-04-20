# frozen_string_literal: true

require_relative 'positions'

# superclass for chess pieces
class Piece
  include Positions

  attr_reader :color, :valid_moves, :current_position

  HORIZONTAL_VERTICAL = [{ x: 1, y: 0 }, { x: -1, y: 0 }, { x: 0, y: 1 }, { x: 0, y: -1 }].freeze

  DIAGONAL = [{ x: 1, y: 1 }, { x: -1, y: -1 }, { x: 1, y: -1 }, { x: -1, y: 1 }].freeze

  def initialize(color, current_position, board)
    @color = color
    @current_position = current_position
    @board = board
    @valid_moves = Set[]
  end

  def update_position(position)
    @current_position = position
  end

  def change_valid_moves
    @valid_moves = all_valid_moves
  end

  def opponent?(position)
    index = get_name_index(position)

    @board.board[index[:x]][index[:y]].color != @color
  end

  def directional_moves(directions)
    moves = Set[]

    directions.each do |direction|
      position = @current_position

      while within_board?(position, direction[:x], direction[:y])
        position = move_pos(position, direction[:x], direction[:y])

        if @board.empty?(position)
          moves.add(position)
        else
          moves.add(position) if opponent?(position)
          break
        end
      end
    end

    moves
  end

  private

  def no_pieces_on_path?(position)
    y_direction = get_direction(@current_position[0], position[0])
    x_direction = get_direction(@current_position[1], position[1])

    cur_position_copy = move_pos(@current_position, x_direction, y_direction)

    until cur_position_copy == position
      return false unless @board.empty?(cur_position_copy)

      cur_position_copy = move_pos(cur_position_copy, x_direction, y_direction)
    end

    true
  end

  def diagonal?(position)
    x_distance = (@current_position[0].ord - position[0].ord).abs
    y_distance = (@current_position[1].ord - position[1].ord).abs

    x_distance == y_distance
  end

  def vertical_horizontal?(position)
    @current_position[0] == position[0] || @current_position[1] == position[1]
  end

  def empty_or_opponent?(position)
    @board.empty?(position) || opponent?(position)
  end

  def get_distance(a_index, b_index)
    (a_index.ord - b_index.ord).abs
  end

  def within_board?(position, x_direction, y_direction)
    index = get_name_index(position)

    x_index = index[:x] + x_direction
    y_index = index[:y] + y_direction

    within_range?(x_index) && within_range?(y_index)
  end

  def possible_moves(directions)
    moves = all_moves(directions)

    moves.delete_if { |move| !empty_or_opponent?(move) }
  end

  def all_moves(directions)
    moves = Set[]
    directions.each do |index|
      next unless within_board?(@current_position, index[0], index[1])

      move = move_pos(@current_position, index[0], index[1])

      moves.add(move)
    end

    moves
  end

  def valid_castling_move?(position)
    !@moved && no_pieces_on_path?(position) && !middle_opponent_controlled?(position)
  end

  def middle_opponent_controlled?(position)
    opponent_pieces = @color == :white ? @board.black_pieces : @board.white_pieces

    mid_squares(position).each do |square|
      opponent_pieces.each do |piece|
        return true if piece.valid_moves.include?(square)
      end
    end

    false
  end

  def mid_squares(position)
    moves = Set[]
    direction = @current_position[0] > position[0] ? -1 : 1

    cur_position = move_pos(@current_position, 0, direction)

    until cur_position == position
      moves.add(cur_position)

      cur_position = move_pos(cur_position, 0, direction)
    end

    moves
  end

  def ally_of_class_has_not_moved?(position, piece_class)
    return false if @board.empty?(position)

    piece = get_piece(position, @board)

    piece.instance_of?(piece_class) && !opponent?(position) && !piece.moved
  end
end
