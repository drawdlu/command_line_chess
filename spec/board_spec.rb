require_relative '../lib/board'
require_relative '../lib/pawn'

describe Board do
  subject(:board) { described_class.new }
  describe '#empty' do
    context 'when spot is empty' do
      it 'will return true' do
        result = board.empty?('A4')
        expect(result).to be_truthy
      end
    end

    context 'when spot is occupied' do
      it 'will return false' do
        sample_board = Array.new(8) { Array.new(8, nil) }
        # 0 is a place holder for some object value since it only checks for nil
        sample_board[3][4] = 0
        board.instance_variable_set(:@board, sample_board)
        result = board.empty?('E5')
        expect(result).to be_falsy
      end
    end
  end

  describe '#move_to' do
    context 'A2 to A4' do
      it 'moves A2 pawn to A4, sets A2 to nil, and does not update opponent list' do
        piece = board.board[6][0]
        board.move_to('A2', 'A4')
        piece_num = board.black_pieces.length
        expect(board.board[6][0]).to be_nil
        expect(board.board[4][0]).to eq(piece)
        expect(piece_num).to eq(16)
      end
    end

    context 'B1 to C3' do
      it 'moves B1 knight to C3, sets B1 to nil, and does not update opponent list' do
        piece = board.board[7][1]
        board.move_to('B1', 'C3')
        piece_num = board.black_pieces.length
        expect(board.board[7][1]).to be_nil
        expect(board.board[5][2]).to eq(piece)
        expect(piece_num).to eq(16)
      end
    end

    context 'B1 to C3 when a piece is in C3' do
      it 'removes C3 opponent from list moves B1 knight to C3 and sets B1 to nil' do
        board.board[5][2] = Pawn.new(:black, 'A1', board)
        piece = board.board[7][1]
        piece_to_remove = board.board[5][2]
        board.move_to('B1', 'C3')
        result = board.black_pieces.include?(piece_to_remove)
        expect(board.board[7][1]).to be_nil
        expect(board.board[5][2]).to eq(piece)
        expect(result).to be_falsy
      end
    end

    context 'C1 to H6 when an opponent is in H6' do
      it 'removes opponent H6 from list, moves C1 bishop to H6, and sets C1 to nil' do
        board.board[2][7] = Pawn.new(:black, 'A1', board)
        piece = board.board[7][2]
        piece_to_remove = board.board[2][7]
        board.move_to('C1', 'H6')
        result = board.black_pieces.include?(piece_to_remove)
        expect(board.board[7][2]).to be_nil
        expect(board.board[2][7]).to eq(piece)
        expect(result).to be_falsy
      end
    end
  end

  describe '#get_back_position' do
    context 'when B6 and :white' do
      let(:pawn) { Pawn.new(:white, 'C5', board) }
      it 'returns B5' do
        result = board.send(:get_back_position, pawn, 'B6')
        expect(result).to eq('B5')
      end
    end

    context 'when B6 and :black' do
      let(:pawn) { Pawn.new(:black, 'B7', board) }
      it 'returns B7' do
        result = board.send(:get_back_position, pawn, 'B6')
        expect(result).to eq('B7')
      end
    end
  end
end
