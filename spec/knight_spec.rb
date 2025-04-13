require_relative '../lib/knight'
require_relative '../lib/board'

describe Knight do
  let(:board) { instance_double(Board) }

  describe '#all_valid_moves' do
    subject(:knight) { described_class.new(:white, 'B1', Board.new) }
    context 'at B1 when no pieces have moved yet' do
      it 'will return Set[A3, C3]' do
        result = knight.all_valid_moves
        expect(result).to eq(Set['A3', 'C3'])
      end
    end

    context 'at D4 when no pieces have moved yet' do
      subject(:knight) { described_class.new(:white, 'D4', Board.new) }
      it 'will return Set[F3, B3, F5, B5, E6, C6]' do
        new_board = knight.instance_variable_get(:@board)
        new_board.board[7][1] = nil
        new_board.board[4][3] = knight
        knight.instance_variable_set(:@board, new_board)
        result = knight.all_valid_moves
        expect(result).to eq(Set['F3', 'B3', 'F5', 'B5', 'E6', 'C6'])
      end
    end
  end
end
