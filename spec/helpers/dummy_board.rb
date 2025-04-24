require_relative '../../lib/board'
require_relative '../../lib/pieces/pawn'
require_relative '../../lib/pieces/bishop'
require_relative '../../lib/pieces/rook'
require_relative '../../lib/pieces/knight'
require_relative '../../lib/pieces/king'
require_relative '../../lib/pieces/queen'
require_relative '../../lib/positions'

module Helpers
  module DummyBoard
    include Positions

    BOARD_SIZE = 8

    # receives an array of piece hashes with color, position, class keys
    def create_dummy(pieces)
      board = create_board

      pieces.each do |piece|
        new_piece = piece[:class].new(piece[:color], piece[:position], board)
        new_piece.instance_variable_set(:@moved, piece[:moved]) if piece.key?(:moved)
        insert_to_board(new_piece)
        update_pieces_list(new_piece)
      end

      update_all_valid_moves(board)

      board
    end

    def insert_piece(piece)
      insert_to_board(piece)
      piece.change_valid_moves
      update_pieces_list(piece)
    end

    def update_all_valid_moves(board)
      update_each_valid_moves(board.white_pieces)
      update_each_valid_moves(board.black_pieces)
    end

    def update_each_valid_moves(pieces_list)
      pieces_list.each(&:change_valid_moves)
    end

    def update_pieces_list(piece)
      board = piece.instance_variable_get(:@board)

      if piece.color == :white
        board.white_pieces.add(piece)
      else
        board.black_pieces.add(piece)
      end
    end

    def insert_to_board(piece)
      index = get_name_index(piece.current_position)
      board = piece.instance_variable_get(:@board)

      new_board = board.instance_variable_get(:@board)
      new_board[index[:x]][index[:y]] = piece

      board.instance_variable_set(:@board, new_board)
    end

    def create_piece(color, position, piece_class, board)
      piece_class.new(color, position, board)
    end

    def create_board
      board = Board.new
      empty_board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, nil) }
      board.instance_variable_set(:@board, empty_board)
      board.instance_variable_set(:@white_pieces, Set[])
      board.instance_variable_set(:@black_pieces, Set[])

      board
    end
  end
end
