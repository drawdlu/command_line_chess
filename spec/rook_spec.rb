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

    context 'D3 to D7 where a piece is in D6' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
      end
      it 'returns False' do
        result = rook.no_pieces_on_path?('D7')
        expect(result).to be_falsy
      end
    end
  end

  describe '#move' do
    context 'D3 to E3 where E3 is empty' do
      before do
        allow(board).to receive(:empty?).and_return(true)
      end

      it 'returns true and updates position value' do
        result = rook.move('E3')
        position = rook.instance_variable_get(:@current_position)
        expect(result).to be_truthy
        expect(position).to eq('E3')
      end
    end

    context 'D3 to E3 where E3 is an opponent' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(rook).to receive(:opponent?).and_return(true)
      end

      it 'returns true and updates position value' do
        result = rook.move('E3')
        position = rook.instance_variable_get(:@current_position)
        expect(result).to be_truthy
        expect(position).to eq('E3')
      end
    end

    context 'D3 to E3 where E3 is an ally' do
      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(rook).to receive(:opponent?).and_return(false)
      end

      it 'returns false and does not update position value' do
        result = rook.move('E3')
        position = rook.instance_variable_get(:@current_position)
        expect(result).to be_falsy
        expect(position).to eq('D3')
      end
    end

    context 'D3 to D7 where there is a piece on D6' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
      end

      it 'returns false and does not update position value' do
        result = rook.move('D7')
        position = rook.instance_variable_get(:@current_position)
        expect(result).to be_falsy
        expect(position).to eq('D3')
      end
    end

    context 'D3 to D8 where theres is an ally on D8' do
      before do
        allow(board).to receive(:empty?).exactly(5).times.and_return(true, true, true, true, false)
        allow(rook).to receive(:opponent?).and_return(false)
      end

      it 'returns false and does not update position value' do
        result = rook.move('D8')
        position = rook.instance_variable_get(:@current_position)
        expect(result).to be_falsy
        expect(position).to eq('D3')
      end
    end
  end
end
