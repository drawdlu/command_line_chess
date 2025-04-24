# frozen_string_literal: true

require_relative 'piece'
require_relative 'positions'
require_relative 'rook'
require_relative 'queen'
require_relative 'bishop'
require_relative 'knight'

# Controls movement and characteristics of a pawn in chess
class Pawn < Piece
  include Positions

  def to_s
    '♟'
  end

  def all_valid_moves
    # white goes up vertically in the 2d array and black goes the opposite way
    # forward movement along y_index
    direction = @color == :white ? -1 : 1
    current_index = get_name_index(@current_position)
    return Set[] unless within_range?(current_index[:x] + direction)

    forward = get_forward_move(current_index[:x], current_index[:y], direction)
    diagonal_moves = get_diagonal_moves(current_index[:x], current_index[:y], direction)
    double = get_double_move(current_index[:x], current_index[:y], direction)

    forward + diagonal_moves + double + en_passant
  end

  def update_position(position)
    @current_position = position
  end

  def promote(input = prompt_for_promote_piece)
    piece_class = convert_to_class(input)
    piece = create_piece_with_valid_moves(piece_class)
    put_piece_on_board(piece)
    remove_pawn_from_list
  end

  def last_row?
    last_row = @color == :white ? '8' : '1'

    @current_position[1] == last_row
  end

  private

  def get_forward_move(x_index, y_index, direction)
    forward = square_name(x_index + direction, y_index)

    @board.empty?(forward) ? Set[forward] : Set[]
  end

  def get_diagonal_moves(x_index, y_index, direction)
    diagonal_moves = Set[]
    diagonal_moves.add(square_name(x_index + direction, y_index + 1)) unless (y_index + 1) == BOARD_SIZE
    diagonal_moves.add(square_name(x_index + direction, y_index - 1)) unless (y_index - 1).negative?
    valid_diagonal_moves = Set[]

    diagonal_moves.each do |move|
      next if @board.empty?(move)

      valid_diagonal_moves << move if opponent?(move)
    end
    valid_diagonal_moves
  end

  def get_double_move(x_index, y_index, direction)
    forward = square_name(x_index + direction, y_index)
    first_position = @color == :white ? 6 : 1

    double = double_move(x_index, y_index, direction, first_position)

    valid_double?(double, forward) ? Set[double] : Set[]
  end

  def valid_double?(double, forward)
    !double.nil? && @board.empty?(double) && @board.empty?(forward)
  end

  def double_move(x_index, y_index, direction, first_position)
    return square_name(x_index + (direction * 2), y_index) if first_position == x_index

    nil
  end

  def en_passant
    last_move = @board.last_move
    return Set[] unless !last_move.nil? && opponent_double_move? && on_left_or_right?

    direction = @color == :white ? -1 : 1
    opponent_position = last_move[:to]
    Set[move_pos(opponent_position, direction, 0)]
  end

  def on_left_or_right?
    opponent_position = @board.last_move[:to]
    index = get_name_index(@current_position)
    left = within_range?(index[:y] - 1) ? move_pos(@current_position, 0, -1) : nil
    right = within_range?(index[:y] + 1) ? move_pos(@current_position, 0, 1) : nil

    opponent_position == left || opponent_position == right
  end

  def opponent_double_move?
    last_move = @board.last_move
    initial_num = @color == :white ? 7 : 2
    direction = @color == :white ? -2 : 2

    last_move[:piece].instance_of?(Pawn) &&
      last_move[:from][1].to_i == initial_num &&
      last_move[:to][1].to_i == initial_num + direction
  end

  def create_piece_with_valid_moves(piece)
    new_piece = piece.new(@color, @current_position, @board)
    new_piece.change_valid_moves
    new_piece
  end

  def put_piece_on_board(piece)
    index = get_name_index(piece.current_position)

    @board.board[index[:x]][index[:y]] = piece
    @color == :white ? @board.white_pieces.add(piece) : @board.black_pieces.add(piece)
    remove_pawn_from_list
  end

  def remove_pawn_from_list
    if @color == :white
      @board.white_pieces.delete_if { |piece| piece == self }
    else
      @board.black_pieces.delete_if { |piece| piece == self }
    end
  end

  def prompt_for_promote_piece
    result = 'not'

    choices = %w[KNIGHT ROOK BISHOP QUEEN]

    loop do
      print 'Enter promotion choice between '
      choices.each do |piece|
        print "#{piece} "
      end
      print ': '

      result = gets.chomp.upcase
      break if choices.join(' ').include?(result)
    end

    result
  end

  def convert_to_class(input)
    promote_pieces = { 'KNIGHT' => Knight, 'QUEEN' => Queen, 'BISHOP' => Bishop, 'ROOK' => Rook }

    promote_pieces.each_key do |key|
      return promote_pieces[key] if key.include?(input)
    end
  end
end
