# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'

describe Pawn do
  let(:board) { instance_double(Board) }

  describe '#valid_moves' do
    context 'white pawn' do
      subject(:piece) { described_class.new(:white, 'C2', board) }

      context 'when no pieces are in front and diagonally' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(true)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('C4').and_return(true)
        end

        it 'will return [C3, C4]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C3 C4])
        end
      end

      context 'when no piece in front and a piece is present to the diagonal right' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(true)
          allow(board).to receive(:empty?).with('D3').and_return(false)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('C4').and_return(true)
        end

        it 'will return [C3, D3]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C3 D3 C4])
        end
      end

      context 'when a piece is in front but not at double and a piece is present on the diagonal left' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(false)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(false)
          allow(board).to receive(:empty?).with('C4').and_return(true)
        end

        it 'will return [B3]' do
          result = piece.valid_moves
          expect(result).to eq(%w[B3])
        end
      end

      context 'when a piece is in front and no pieces diagonally' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(false)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('C4').and_return(true)
        end

        it 'will return []' do
          result = piece.valid_moves
          expect(result).to eq([])
        end
      end

      context 'when a piece is at A2 and no pieces in front and diagonal' do
        subject(:piece) { described_class.new(:white, 'A2', board) }
        before do
          allow(board).to receive(:empty?).with('A3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('A4').and_return(true)
        end
        it 'will return [A3 A4]' do
          result = piece.valid_moves
          expect(result).to eq(%w[A3 A4])
        end
      end

      context 'when a piece is at H2 and no pieces in front and diagonal' do
        subject(:piece) { described_class.new(:white, 'H2', board) }
        before do
          allow(board).to receive(:empty?).with('H3').and_return(true)
          allow(board).to receive(:empty?).with('G3').and_return(true)
          allow(board).to receive(:empty?).with('H4').and_return(true)
        end
        it 'will return [H3 H4]' do
          result = piece.valid_moves
          expect(result).to eq(%w[H3 H4])
        end
      end
    end

    context 'black pawn' do
      subject(:piece) { described_class.new(:black, 'C7', board) }
      context 'when no pieces are in front and diagonally' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(true)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('C5').and_return(true)
        end

        it 'will return [C6 C5]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C6 C5])
        end
      end

      context 'when no piece in front and a piece is present to the right' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(true)
          allow(board).to receive(:empty?).with('D6').and_return(false)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('C5').and_return(true)
        end

        it 'will return [C6, D6, C5]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C6 D6 C5])
        end
      end

      context 'when a piece is in front and a piece is present on the left and no piece is at double' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(false)
          allow(board).to receive(:empty?).with('C5').and_return(true)
        end

        it 'will return [B6]' do
          result = piece.valid_moves
          expect(result).to eq(%w[B6])
        end
      end

      context 'when a piece is in front and no pieces diagonally' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('C5').and_return(true)
        end

        it 'will return []' do
          result = piece.valid_moves
          expect(result).to eq([])
        end
      end

      context 'when a piece is at A7 and no pieces in front and diagonal' do
        subject(:piece) { described_class.new(:black, 'A7', board) }
        before do
          allow(board).to receive(:empty?).with('A6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('A5').and_return(true)
        end
        it 'will return [A6 A5]' do
          result = piece.valid_moves
          expect(result).to eq(%w[A6 A5])
        end
      end

      context 'when a piece is at H5 and no pieces in front and diagonal' do
        subject(:piece) { described_class.new(:black, 'H5', board) }
        before do
          allow(board).to receive(:empty?).with('H4').and_return(true)
          allow(board).to receive(:empty?).with('G4').and_return(true)
        end
        it 'will return [H4]' do
          result = piece.valid_moves
          expect(result).to eq(['H4'])
        end
      end
    end
  end

  describe '#move' do
    subject(:piece) { described_class.new(:white, 'A2', board) }
    context 'when moving from A2 to A3 and no piece is in A3' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(true)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return the move A3 and update current_position' do
        result = piece.move('A3')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to eq('A3')
        expect(current_position).to eq('A3')
      end
    end

    context 'when moving from A2 to non valid move A5' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(true)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return nil and does not update current_position' do
        result = piece.move('A5')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to eq(nil)
        expect(current_position).to eq('A2')
      end
    end

    context 'when moving from A2 to a valid double move A4' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(true)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return A4 and update current_position' do
        result = piece.move('A4')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to eq('A4')
        expect(current_position).to eq('A4')
      end
    end

    context 'when moving from A2 to a invalid double move because a piece is in single move' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(false)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return nil and does not update current position' do
        result = piece.move('A4')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to eq(nil)
        expect(current_position).to eq('A2')
      end
    end
  end
end
