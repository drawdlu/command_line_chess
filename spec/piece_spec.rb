require_relative '../lib/piece'
require_relative '../lib/board'
describe Piece do
  let(:board) { instance_double(Board) }
  subject(:piece) { described_class.new(:white, 'A5', board) }

  describe '#move_pos' do
    context 'when A5 is passed and 0, 1 as direction' do
      it 'will return A6' do
        result = piece.move_pos('A5', 0, 1)
        expect(result).to eq('A6')
      end
    end

    context 'when A5 is passed and 0, -1 as direction' do
      it 'will return A4' do
        result = piece.move_pos('A5', 0, -1)
        expect(result).to eq('A4')
      end
    end

    context 'when A5 is passed and 2, -1 as direction' do
      it 'will return C4' do
        result = piece.move_pos('A5', 2, -1)
        expect(result).to eq('C4')
      end
    end
  end
end
