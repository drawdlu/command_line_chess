# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../lib/board'

describe Rook do
  let(:board) { instance_double(Board) }
  subject(:rook) { described_class.new(:white, 'D3', board) }

  describe '#horizontal_or_vertical_move?' do
    context 'D3 to H3' do
      it 'returns True' do
        result = rook.horizontal_or_vertical_move?('H3')
        expect(result).to be_truthy
      end
    end

    context 'D3 to D6' do
      it 'returns True' do
        result = rook.horizontal_or_vertical_move?('D6')
        expect(result).to be_truthy
      end
    end

    context 'D3 to A2' do
      it 'returns False' do
        result = rook.horizontal_or_vertical_move?('A2')
        expect(result).to be_falsy
      end
    end
  end

  describe '#no_pieces_on_path?' do
    context 'D3 to D6 and no pieces are in path' do
      before do
        allow(board).to receive(:empty?).twice.and_return(true)
      end

      it 'returns True' do
        result = rook.no_pieces_on_path?('D6')
        expect(result).to be_truthy
      end
    end

    context 'D3 to D4' do
      it 'returns True' do
        result = rook.no_pieces_on_path?('D4')
        expect(result).to be_truthy
      end
    end

    context 'D3 to B3 and a piece is in C3' do
      before do
        allow(board).to receive(:empty?).with('C3').and_return(false)
      end
      it 'returns False' do
        result = rook.no_pieces_on_path?('B3')
        expect(result).to be_falsy
      end
    end
  end
end
