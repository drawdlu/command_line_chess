require_relative '../lib/board'

describe Board do
  subject(:board) { described_class.new }
  describe '#empty' do
    context 'when spot is empty' do
      it 'will return true' do
        result = board.empty?('A1')
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
end
