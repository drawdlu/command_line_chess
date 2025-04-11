# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../lib/board'

describe Rook do
  let(:board) { instance_double(Board) }
  subject(:rook) { described_class.new(:white, 'D3', board) }

  describe '#valid_move?' do
    context 'D3 to E3 where E3 is empty' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'returns true and updates position value' do
        result = rook.valid_move?('E3')
        expect(result).to be_truthy
      end
    end

    context 'D3 to E3 where E3 is an opponent' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(rook).to receive(:opponent?).and_return(true)
      end

      it 'returns true and updates position value' do
        result = rook.valid_move?('E3')
        expect(result).to be_truthy
      end
    end

    context 'D3 to E3 where E3 is an ally' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(rook).to receive(:opponent?).and_return(false)
      end

      it 'returns false and does not update position value' do
        result = rook.valid_move?('E3')
        expect(result).to be_falsy
      end
    end

    context 'D3 to D7 where there is a piece on D6' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
      end

      it 'returns false and does not update position value' do
        result = rook.valid_move?('D7')
        expect(result).to be_falsy
      end
    end

    context 'D3 to D8 where theres is an ally on D8' do
      before do
        allow(board).to receive(:empty?).exactly(5).times.and_return(true, true, true, true, false)
        allow(rook).to receive(:opponent?).and_return(false)
      end

      it 'returns false and does not update position value' do
        result = rook.valid_move?('D8')
        expect(result).to be_falsy
      end
    end
  end
end
