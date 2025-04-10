require_relative '../lib/king'
require_relative '../lib/board'

describe King do
  let(:board) { instance_double(Board) }
  subject(:king) { described_class.new(:white, 'D4', board) }

  describe '#valid_move?' do
    context 'D4 to C5 when no piece around' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'returns true' do
        result = king.valid_move?('C5')
        expect(result).to be_truthy
      end
    end

    context 'D4 to D5 when an opponent is in D5' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(king).to receive(:opponent?).and_return(true)
      end

      it 'returns true' do
        result = king.valid_move?('D5')
        expect(result).to be_truthy
      end
    end

    context 'D4 to E3 when an ally is in E3' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(king).to receive(:opponent?).and_return(false)
      end

      it 'returns false' do
        result = king.valid_move?('E3')
        expect(result).to be_falsy
      end
    end

    context 'D4 to D6' do
      it 'returns false' do
        result = king.valid_move?('D6')
        expect(result).to be_falsy
      end
    end
  end
end
