# frozen_string_literal: true

require_relative 'positions'
require_relative 'pawn'
require_relative 'rook'
require_relative 'bishop'
require_relative 'knight'
require_relative 'queen'
require_relative 'king'

# Handles state of board
class Board
  include Positions

  attr_reader :board, :black_pieces, :white_pieces, :last_move

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @black_pieces = Set[]
    @white_pieces = Set[]
    @last_move = nil
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
    @board[index[:x]][index[:y]].nil?
  end

  def move_to(initial_position, position)
    initial_index = get_name_index(initial_position)
    new_index = get_name_index(position)

    handle_en_passant(initial_position, position)
    move_piece(initial_index, new_index)
  end

  def update_last_move(from, to, piece)
    @last_move = { from: from, to: to, piece: piece }
  end

  def update_valid_moves
    update_moves_set(@black_pieces)
    update_moves_set(@white_pieces)
  end

  def handle_castling_move(position1, position2)
    king_index = get_position_index(position1, position2, King)
    rook_index = get_position_index(position1, position2, Rook)
    final_king_index = get_final_pos(rook_index, King)
    final_rook_index = get_final_pos(rook_index, Rook)

    update_piece_position(king_index, final_king_index)
    update_piece_position(rook_index, final_rook_index)
    move_piece(king_index, final_king_index)
    move_piece(rook_index, final_rook_index)
  end

  private

  def update_piece_position(initial_index, final_index)
    initial_pos = square_name(initial_index[:x], initial_index[:y])
    final_pos = square_name(final_index[:x], final_index[:y])
    piece = get_piece(initial_pos)
    piece.update_position(final_pos)
  end

  def get_final_pos(rook_index, piece_class)
    rook_position = square_name(rook_index[:x], rook_index[:y])
    final_pos_letter = if piece_class == King
                         rook_position[0] == 'A' ? 'C' : 'G'
                       else
                         rook_position[0] == 'A' ? 'D' : 'F'
                       end
    get_name_index("#{final_pos_letter}#{rook_position[1]}")
  end

  def get_position_index(position1, position2, piece_class)
    position = if piece_class == King
                 position1[0] == 'E' ? position1 : position2
               else
                 position1[0] == 'E' ? position2 : position1
               end
    get_name_index(position)
  end

  def handle_en_passant(initial_position, position)
    piece = get_piece(initial_position)
    return unless move_is_en_passant?(position, piece)

    delete_piece(position, piece)
  end

  def delete_piece(final_position, piece_to_move)
    back_position = get_back_position(piece_to_move, final_position)
    back_piece = get_piece(back_position)

    index = get_name_index(back_position)

    board[index[:x]][index[:y]] = nil

    remove_piece(back_piece)
  end

  def move_is_en_passant?(position, piece_to_move)
    piece_to_move.instance_of?(Pawn) &&
      empty?(position) &&
      opponent_pawn_behind_final_position?(piece_to_move, position)
  end

  def opponent_pawn_behind_final_position?(piece, final_position)
    back_position = get_back_position(piece, final_position)

    piece.opponent?(back_position) unless empty?(back_position)
  end

  def get_back_position(piece, final_position)
    color = piece.color
    back_direction = color == :white ? 1 : -1

    move_pos(final_position, back_direction, 0)
  end

  def move_piece(initial_index, new_index)
    destination_value = board[new_index[:x]][new_index[:y]]
    piece_to_move = board[initial_index[:x]][initial_index[:y]]
    board[new_index[:x]][new_index[:y]] = piece_to_move
    board[initial_index[:x]][initial_index[:y]] = nil

    remove_piece(destination_value) unless destination_value.nil?
  end

  def remove_piece(piece)
    piece.color == :white ? white_pieces.delete(piece) : black_pieces.delete(piece)
  end

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
      color == :white ? white_pieces.add(pawn) : black_pieces.add(pawn)
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
      color == :white ? white_pieces.add(piece) : black_pieces.add(piece)
      line.push(piece)
    end

    line
  end

  def row(row, x_index)
    row_string = space
    row.each_with_index do |val, y_index|
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

  def update_moves_set(set_pieces)
    set_pieces.each(&:change_valid_moves)
  end

  def includes_last_move(piece)
    piece.valid_moves.include?(@last_move[:from]) ||
      piece.valid_moves.include?(@last_move[:to])
  end
end
