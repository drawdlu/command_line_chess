require_relative '../lib/board'

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
      it 'moves A2 pawn to A4 and sets A2 to nil' do
        piece = board.board[6][0]
        board.move_to('A2', 'A4')
        expect(board.board[6][0]).to be_nil
        expect(board.board[4][0]).to eq(piece)
      end
    end

    context 'B1 to C3' do
      it 'moves B1 knight to C3 and sets B1 to nil' do
        piece = board.board[7][1]
        board.move_to('B1', 'C3')
        expect(board.board[7][1]).to be_nil
        expect(board.board[5][2]).to eq(piece)
      end
    end
  end
end
