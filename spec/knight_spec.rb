require_relative '../lib/knight'
require_relative '../lib/board'

describe Knight do
  let(:board) { instance_double(Board) }
  subject(:knight) { described_class.new(:white, 'D4', board) }
  describe '#valid_move?' do
    context 'when D4 to F5' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'will return True' do
        result = knight.valid_move?('F5')
        expect(result).to be_truthy
      end
    end

    context 'when D4 to C2' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'will return True' do
        result = knight.valid_move?('C2')
        expect(result).to be_truthy
      end
    end

    context 'when D4 to B2, not a valid knight move' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'will return False' do
        result = knight.valid_move?('B2')
        expect(result).to be_falsy
      end
    end

    context 'when D4 to B5 and an opponent is on B5' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(knight).to receive(:opponent?).and_return(true)
      end

      it 'will return True' do
        result = knight.valid_move?('B5')
        expect(result).to be_truthy
      end
    end

    context 'when D4 to B5 and an ally is on B5' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(knight).to receive(:opponent?).and_return(false)
      end

      it 'will return True' do
        result = knight.valid_move?('B5')
        expect(result).to be_falsy
      end
    end
  end
end
