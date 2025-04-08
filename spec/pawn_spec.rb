# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'

describe Pawn do
  let(:board) { instance_double(Board) }
  subject(:piece) { described_class.new(:white, 'C2', board) }

  describe '#valid_moves' do
    context 'white pawn' do
      subject(:piece) { described_class.new(:white, 'C2', board) }

      context 'when no pieces are in front and diagonally' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(true)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(true)
        end

        it 'will return [C3]' do
          result = piece.valid_moves
          expect(result).to eq(['C3'])
        end
      end

      context 'when no piece in front and a piece is present to the diagonal right' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(true)
          allow(board).to receive(:empty?).with('D3').and_return(false)
          allow(board).to receive(:empty?).with('B3').and_return(true)
        end

        it 'will return [C3, D3]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C3 D3])
        end
      end

      context 'when a piece is in front and a piece is present on the diagonal left' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(false)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(false)
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
        end
        it 'will return [A3]' do
          result = piece.valid_moves
          expect(result).to eq(['A3'])
        end
      end

      context 'when a piece is at H2 and no pieces in front and diagonal' do
        subject(:piece) { described_class.new(:white, 'H2', board) }
        before do
          allow(board).to receive(:empty?).with('H3').and_return(true)
          allow(board).to receive(:empty?).with('G3').and_return(true)
        end
        it 'will return [H3]' do
          result = piece.valid_moves
          expect(result).to eq(['H3'])
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
        end

        it 'will return [C6]' do
          result = piece.valid_moves
          expect(result).to eq(['C6'])
        end
      end

      context 'when no piece in front and a piece is present to the right' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(true)
          allow(board).to receive(:empty?).with('D6').and_return(false)
          allow(board).to receive(:empty?).with('B6').and_return(true)
        end

        it 'will return [C6, D6]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C6 D6])
        end
      end

      context 'when a piece is in front and a piece is present on the left' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(false)
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
        end
        it 'will return [A6]' do
          result = piece.valid_moves
          expect(result).to eq(['A6'])
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
end
