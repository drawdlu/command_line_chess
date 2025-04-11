require_relative '../lib/queen'
require_relative '../lib/board'

describe Queen do
  let(:board) { instance_double(Board) }
  subject(:queen) { described_class.new(:white, 'D4', board) }
  describe '#valid_move?' do
    context 'D4 to G7 no pieces around' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true)
      end

      it 'returns True' do
        result = queen.valid_move?('G7')
        expect(result).to be_truthy
      end
    end

    context 'D4 to G7 with an opponent piece on G7' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
        allow(queen).to receive(:opponent?).and_return(true)
      end

      it 'returns True' do
        result = queen.valid_move?('G7')
        expect(result).to be_truthy
      end
    end

    context 'D4 to G7 with an ally piece on G7' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
        allow(queen).to receive(:opponent?).and_return(false)
      end

      it 'returns False' do
        result = queen.valid_move?('G7')
        expect(result).to be_falsy
      end
    end

    context 'D4 to D3 with no piece on D3' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'returns True' do
        result = queen.valid_move?('D3')
        expect(result).to be_truthy
      end
    end

    context 'D4 to D8 with no piece on D8 but a piece on D6' do
      before do
        allow(board).to receive(:empty?).with('D5').and_return(true)
        allow(board).to receive(:empty?).with('D6').and_return(false)
      end

      it 'returns False' do
        result = queen.valid_move?('D8')
        expect(result).to be_falsy
      end
    end

    context 'D4 to B5, not a valid Queen move' do
      it 'returns False' do
        result = queen.valid_move?('B5')
        expect(result).to be_falsy
      end
    end
  end
end
