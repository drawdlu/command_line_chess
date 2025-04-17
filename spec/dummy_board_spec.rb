require_relative 'helpers/dummy_board'
require_relative '../lib/board'
require_relative '../lib/rook'

describe Helpers::DummyBoard do
  let(:dummy_board) { Class.new { extend Helpers::DummyBoard } }
  let(:board_size) { Helpers::DummyBoard::BOARD_SIZE }
  let(:board) { instance_double(Board) }

  describe '#create_board' do
    it 'returns an empty board' do
      result = dummy_board.create_board
      board = result.board
      white_pieces = result.instance_variable_get(:@white_pieces)
      black_pieces = result.instance_variable_get(:@black_pieces)
      (0..board_size - 1).each do |index|
        empty = board[index].all?(nil)
        expect(empty).to be_truthy
      end
      expect(white_pieces).to be_empty
      expect(black_pieces).to be_empty
    end
  end

  describe '#create_piece' do
    context 'when :white, A1, Rook' do
      it 'returns an Object with said values' do
        color = :white
        position = 'A1'
        piece_class = Rook
        result = dummy_board.create_piece(color, position, piece_class, board)
        piece_board = result.instance_variable_get(:@board)
        expect(result).to have_attributes(color: color, current_position: position)
        expect(piece_board).to eq(board)
      end
    end
  end

  describe '#insert_to_board' do
    context 'when board is empty, Rook at A1' do
      it 'inserts that piece into [7][0] of board' do
        board = dummy_board.create_board
        piece = Rook.new(:white, 'A1', board)
        dummy_board.insert_to_board(piece)
        board_position = board.board[7][0]
        expect(board_position).to eq(piece)
      end
    end
  end

  describe '#update_pieces_list' do
    it 'will add the piece to list' do
      board = dummy_board.create_board
      piece = Rook.new(:white, 'A1', board)
      dummy_board.update_pieces_list(piece)
      result = board.white_pieces.include?(piece)
      expect(result).to be_truthy
    end
  end

  describe '#create_dummy' do
    context 'when 2 pieces hashes are passed in' do
      it 'will return the board with those 2 pieces' do
        pieces = [{ color: :white, position: 'A1', class: Rook },
                  { color: :white, position: 'H1', class: Rook }]
        result = dummy_board.create_dummy(pieces)
        white_pieces_num = result.white_pieces.length
        piece1 = !result.board[7][0].nil?
        piece2 = !result.board[7][7].nil?
        black_pieces_num = result.black_pieces.length
        expect(white_pieces_num).to eq(2)
        expect(black_pieces_num).to eq(0)
        expect(piece1).to be_truthy
        expect(piece2).to be_truthy
      end
    end
  end
end
