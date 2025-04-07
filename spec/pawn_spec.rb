# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'

describe Pawn do
  let(:board) { instance_double(Board) }
  subject(:piece) { described_class.new(:white, 'C2', board) }

  describe '#valid_moves' do
    context 'white pawn' do
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
    end
  end
end
