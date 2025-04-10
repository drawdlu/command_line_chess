# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'

describe Pawn do
  let(:board) { instance_double(Board) }
  let(:sample_board) { Array.new(8) { Array.new(8, nil) } }

  describe '#valid_moves' do
    context 'white pawn' do
      subject(:piece) { described_class.new(:white, 'C2', board) }

      context 'C2 when no pieces are in front and diagonally' do
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

      context 'C2 when an opponent piece is in D3' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(true)
          allow(board).to receive(:empty?).with('D3').and_return(false)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('C4').and_return(true)
          allow(piece).to receive(:opponent?).and_return(true)
        end

        it 'will return [C3, D3, C4]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C3 D3 C4])
        end
      end

      context 'C2 when an ally piece is in D3 and an opponent is in C3' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(false)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(false)
          allow(board).to receive(:empty?).with('C4').and_return(true)
          allow(piece).to receive(:opponent?).and_return(false)
        end

        it 'will return []' do
          result = piece.valid_moves
          expect(result).to eq([])
        end
      end

      context 'C2 when an opponent is in C3' do
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

      context 'A2 when no pieces in possible moves' do
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

      context 'H2 when no pieces around' do
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
      context 'C7 when no pieces around' do
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

      context 'C7 when an opponent piece is in D6' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(true)
          allow(board).to receive(:empty?).with('D6').and_return(false)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('C5').and_return(true)
          allow(piece).to receive(:opponent?).and_return(true)
        end

        it 'will return [C6, D6, C5]' do
          result = piece.valid_moves
          expect(result).to eq(%w[C6 D6 C5])
        end
      end

      context 'C7 when an opponent is in C6 and an ally in B6' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(false)
          allow(board).to receive(:empty?).with('C5').and_return(true)
          allow(piece).to receive(:opponent?).and_return(false)
        end

        it 'will return []' do
          result = piece.valid_moves
          expect(result).to eq([])
        end
      end

      context 'C7 when an opponent is in C6 an an ally in B6' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(false)
          allow(board).to receive(:empty?).with('C5').and_return(true)
          allow(piece).to receive(:opponent?).and_return(false)
        end

        it 'will return []' do
          result = piece.valid_moves
          expect(result).to eq([])
        end
      end

      context 'A7 when no pieces around' do
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

      context 'H5 when no pieces around' do
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
    context 'A2 to A3 and no piece in A3' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(true)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return true and update current position' do
        result = piece.move('A3')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to be_truthy
        expect(current_position).to eq('A3')
      end
    end

    context 'A2 to A5 non valid move' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(true)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return false and does not update current_position' do
        result = piece.move('A5')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to be_falsy
        expect(current_position).to eq('A2')
      end
    end

    context 'A2 to A4 double move' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(true)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return true and update current_position' do
        result = piece.move('A4')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to be_truthy
        expect(current_position).to eq('A4')
      end
    end

    context 'A2 to A4 when a piece is in A3' do
      before do
        allow(board).to receive(:empty?).with('A3').and_return(false)
        allow(board).to receive(:empty?).with('B3').and_return(true)
        allow(board).to receive(:empty?).with('A4').and_return(true)
      end

      it 'will return false and does not update current position' do
        result = piece.move('A4')
        current_position = piece.instance_variable_get(:@current_position)
        expect(result).to be_falsy
        expect(current_position).to eq('A2')
      end
    end
  end
end
