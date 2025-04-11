require_relative '../lib/piece'
require_relative '../lib/board'
require_relative '../lib/rook'

describe Piece do
  let(:board) { instance_double(Board) }
  subject(:piece) { described_class.new(:white, 'A5', board) }

  describe '#move_pos' do
    context 'when A5 is passed and 0, 1 as direction' do
      it 'will return A6' do
        result = piece.send(:move_pos, 'A5', 0, 1)
        expect(result).to eq('A6')
      end
    end

    context 'when A5 is passed and 0, -1 as direction' do
      it 'will return A4' do
        result = piece.send(:move_pos, 'A5', 0, -1)
        expect(result).to eq('A4')
      end
    end

    context 'when A5 is passed and 2, -1 as direction' do
      it 'will return C4' do
        result = piece.send(:move_pos, 'A5', 2, -1)
        expect(result).to eq('C4')
      end
    end
  end

  describe '#no_pieces_on_path?' do
    subject(:piece) { described_class.new(:white, 'D3', board) }
    context 'D3 to D6 and no pieces are in path' do
      before do
        allow(board).to receive(:empty?).twice.and_return(true)
      end

      it 'returns True' do
        result = piece.send(:no_pieces_on_path?, 'D6')
        expect(result).to be_truthy
      end
    end

    context 'D3 to D4' do
      it 'returns True' do
        result = piece.send(:no_pieces_on_path?, 'D4')
        expect(result).to be_truthy
      end
    end

    context 'D3 to B3 and a piece is in C3' do
      before do
        allow(board).to receive(:empty?).with('C3').and_return(false)
      end
      it 'returns False' do
        result = piece.send(:no_pieces_on_path?, 'B3')
        expect(result).to be_falsy
      end
    end

    context 'D3 to D7 where a piece is in D6' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
      end
      it 'returns False' do
        result = piece.send(:no_pieces_on_path?, 'D7')
        expect(result).to be_falsy
      end
    end
  end
end
