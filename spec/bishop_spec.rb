require_relative '../lib/bishop'
require_relative '../lib/board'

describe Bishop do
  let(:board) { instance_double(Board) }
  subject(:bishop) { described_class.new(:white, 'D4', board) }
  describe '#valid_move?' do
    context 'when D4 to G7 when there is no piece on G7' do
      before do
        allow(board).to receive(:empty?).exactly(4).times.and_return(true)
      end

      it 'will return True' do
        result = bishop.valid_move?('G7')
        expect(result).to be_truthy
      end
    end

    context 'when D4 to B6 and there is a piece on C5' do
      before do
        allow(board).to receive(:empty?).with('C5').and_return(false)
      end

      it 'will return False' do
        result = bishop.valid_move?('B6')
        expect(result).to be_falsy
      end
    end

    context 'when D4 to G2 not a valid Bishop move' do
      it 'will return False' do
        result = bishop.valid_move?('G2')
        expect(result).to be_falsy
      end
    end

    context 'when D4 to D8 not a valid Bishop move, same letter' do
      it 'will return False' do
        result = bishop.valid_move?('D8')
        expect(result).to be_falsy
      end
    end

    context 'when D4 to B4 not a valid Bishop move, same number' do
      it 'will return False' do
        result = bishop.valid_move?('B4')
        expect(result).to be_falsy
      end
    end

    context 'when D4 to B2 and there is an opponent on B2' do
      before do
        allow(board).to receive(:empty?).with('C3').and_return(true)
        allow(board).to receive(:empty?).with('B2').and_return(false)
        allow(bishop).to receive(:opponent?).and_return(true)
      end

      it 'will return True' do
        result = bishop.valid_move?('B2')
        expect(result).to be_truthy
      end
    end

    context 'when D4 to B2 and there is an ally on B2' do
      before do
        allow(board).to receive(:empty?).with('C3').and_return(true)
        allow(board).to receive(:empty?).with('B2').and_return(false)
        allow(bishop).to receive(:opponent?).and_return(false)
      end

      it 'will return False' do
        result = bishop.valid_move?('B2')
        expect(result).to be_falsy
      end
    end
  end
end
