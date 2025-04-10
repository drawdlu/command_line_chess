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

  describe '#get_positions' do
    context 'when white is passed in' do
      it 'will return positions A1-H1' do
        result = board.send(:get_positions, :white)
        expected_result = %w[A1 B1 C1 D1 E1 F1 G1 H1]
        expect(result).to eq(expected_result)
      end
    end

    context 'when white is passed in' do
      it 'will return positions A8-H8' do
        result = board.send(:get_positions, :black)
        expected_result = %w[A8 B8 C8 D8 E8 F8 G8 H8]
        expect(result).to eq(expected_result)
      end
    end
  end
end
