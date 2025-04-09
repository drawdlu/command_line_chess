# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../lib/board'

describe Rook do
  describe '#horizontal_or_vertical_move?' do
    let(:board) { instance_double(Board) }
    subject(:rook) { described_class.new(:white, 'D3', board) }
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
end
