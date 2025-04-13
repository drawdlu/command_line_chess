require_relative '../lib/bishop'
require_relative '../lib/board'

describe Bishop do
  let(:board) { instance_double(Board) }
  subject(:bishop) { described_class.new(:white, 'C1', Board.new) }

  describe '#all_valid_moves' do
    context 'when piece at C1 and no pieces have moved yet' do
      it 'returns Set[]' do
        result = bishop.all_valid_moves
        expect(result).to be_empty
      end
    end

    context 'when D2 is empty and ally in E3' do
      let(:ally) { Rook.new(:white, 'E3', board) }

      it 'returns Set[D2]' do
        new_board = bishop.instance_variable_get(:@board)
        new_board.board[6][3] = nil
        new_board.board[5][4] = ally
        bishop.instance_variable_set(:@board, new_board)
        result = bishop.all_valid_moves
        expect(result).to eq(Set['D2'])
      end
    end

    context 'when D2 is empty and ally in E3' do
      let(:ally) { Rook.new(:black, 'E3', board) }

      it 'returns Set[D2, E3]' do
        new_board = bishop.instance_variable_get(:@board)
        new_board.board[6][3] = nil
        new_board.board[5][4] = ally
        bishop.instance_variable_set(:@board, new_board)
        result = bishop.all_valid_moves
        expect(result).to eq(Set['D2', 'E3'])
      end
    end
  end
end
