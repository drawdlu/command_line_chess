require_relative '../lib/pieces/king'
require_relative '../lib/pieces/rook'
require_relative '../lib/board'

describe King do
  let(:board) { instance_double(Board) }
  subject(:king) { described_class.new(:white, 'D4', board) }

  describe '#all_valid_moves' do
    subject(:king) { described_class.new(:white, 'E1', Board.new) }
    context 'when it is at start and no pieces has moved' do
      it 'will return Set[]' do
        result = king.all_valid_moves
        expect(result).to be_empty
      end
    end

    context 'when it is at start and E2 is empty' do
      it 'will return Set[E2]' do
        new_board = king.instance_variable_get(:@board)
        new_board.board[6][4] = nil
        king.instance_variable_set(:@board, new_board)
        result = king.all_valid_moves
        expect(result).to eq(Set['E2'])
      end
    end

    context 'when it is at start and E2 is empty' do
      subject(:king) { described_class.new(:white, 'D4', Board.new) }
      it 'will return Set[E3, C3, D3, E5, C5, D5, E4, C4]' do
        new_board = king.instance_variable_get(:@board)
        new_board.board[4][3] = king
        king.instance_variable_set(:@board, new_board)
        result = king.all_valid_moves
        expect(result).to eq(Set['E3', 'C3', 'D3', 'E5', 'C5', 'D5', 'E4', 'C4'])
      end
    end
  end

  describe '#castling' do
    let(:pieces) do
      [{ color: :white, position: 'E1', class: King },
       { color: :white, position: 'H1', class: Rook },
       { color: :white, position: 'A1', class: Rook }]
    end
    let(:board) { create_dummy(pieces) }

    context 'when both king and both rook have not moved' do
      it 'will return positions of both Rooks' do
        king = board.board[7][4]
        result = king.send(:castling)
        rook_positions = Set['H1', 'A1']
        expect(result).to eq(rook_positions)
      end
    end

    context 'when both king and both rook have not moved but enemy controls B1' do
      it 'will return only the right Rook' do
        piece = Rook.new(:black, 'B7', board)
        insert_piece(piece)
        king = board.board[7][4]
        result = king.send(:castling)
        rook_positions = Set['H1']
        expect(result).to eq(rook_positions)
      end
    end

    context 'when rook on right has moved but left is valid castling' do
      it 'will return the left rook' do
        board.board[7][7].instance_variable_set(:@moved, true)
        king = board.board[7][4]
        result = king.send(:castling)
        rook_positions = Set['A1']
        expect(result).to eq(rook_positions)
      end
    end

    context 'when king has moved' do
      it 'will return an empty set' do
        king = board.board[7][4]
        king.instance_variable_set(:@moved, true)
        result = king.send(:castling)
        empty_set = Set[]
        expect(result).to eq(empty_set)
      end
    end
  end
end
