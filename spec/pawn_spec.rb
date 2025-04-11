# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'

describe Pawn do
  let(:board) { instance_double(Board) }
  let(:sample_board) { Array.new(8) { Array.new(8, nil) } }

  describe '#valid_move?' do
    context 'white pawn' do
      subject(:piece) { described_class.new(:white, 'C2', board) }

      context 'C2 when no pieces are in front and diagonally' do
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('C3')
          expect(result).to be_truthy
        end
      end

      context 'C2 to D3 when an opponent piece is in D3' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(true)
          allow(board).to receive(:empty?).with('D3').and_return(false)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('C4').and_return(true)
          allow(piece).to receive(:opponent?).and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('D3')
          expect(result).to be_truthy
        end
      end

      context 'C2 to C3 when an ally piece is in D3 and an opponent is in C3' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(false)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(false)
          allow(board).to receive(:empty?).with('C4').and_return(true)
          allow(piece).to receive(:opponent?).and_return(false)
        end

        it 'will return false' do
          result = piece.valid_move?('C3')
          expect(result).to be_falsy
        end
      end

      context 'C2 to C4 when an opponent is in C3' do
        before do
          allow(board).to receive(:empty?).with('C3').and_return(false)
          allow(board).to receive(:empty?).with('D3').and_return(true)
          allow(board).to receive(:empty?).with('B3').and_return(true)
          allow(board).to receive(:empty?).with('C4').and_return(true)
        end

        it 'will return false' do
          result = piece.valid_move?('C4')
          expect(result).to be_falsy
        end
      end

      context 'A2 to A4 when no pieces around' do
        subject(:piece) { described_class.new(:white, 'A2', board) }
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return True' do
          result = piece.valid_move?('A4')
          expect(result).to be_truthy
        end
      end

      context 'H2 to H3 when no pieces around' do
        subject(:piece) { described_class.new(:white, 'H2', board) }
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('H3')
          expect(result).to be_truthy
        end
      end

      context 'H2 to H5 not a valid move' do
        subject(:piece) { described_class.new(:white, 'H2', board) }
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return false' do
          result = piece.valid_move?('H5')
          expect(result).to be_falsy
        end
      end

      context 'H3 to H5 not a valid move' do
        subject(:piece) { described_class.new(:white, 'H3', board) }
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return false' do
          result = piece.valid_move?('H5')
          expect(result).to be_falsy
        end
      end
    end

    context 'black pawn' do
      subject(:piece) { described_class.new(:black, 'C7', board) }
      context 'C7 to C6 when no pieces around' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(true)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('C5').and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('C6')
          expect(result).to be_truthy
        end
      end

      context 'C7 to D6 when an opponent piece is in D6' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(true)
          allow(board).to receive(:empty?).with('D6').and_return(false)
          allow(board).to receive(:empty?).with('B6').and_return(true)
          allow(board).to receive(:empty?).with('C5').and_return(true)
          allow(piece).to receive(:opponent?).and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('D6')
          expect(result).to be_truthy
        end
      end

      context 'C7 to B6 when an ally in B6' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(false)
          allow(board).to receive(:empty?).with('C5').and_return(true)
          allow(piece).to receive(:opponent?).and_return(false)
        end

        it 'will false' do
          result = piece.valid_move?('B6')
          expect(result).to be_falsy
        end
      end

      context 'C7 to C6 when an opponent in C6' do
        before do
          allow(board).to receive(:empty?).with('C6').and_return(false)
          allow(board).to receive(:empty?).with('D6').and_return(true)
          allow(board).to receive(:empty?).with('B6').and_return(false)
          allow(board).to receive(:empty?).with('C5').and_return(true)
          allow(piece).to receive(:opponent?).and_return(false)
        end

        it 'will return false' do
          result = piece.valid_move?('C6')
          expect(result).to be_falsy
        end
      end

      context 'A7 to A5 when no pieces around' do
        subject(:piece) { described_class.new(:black, 'A7', board) }
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('A5')
          expect(result).to be_truthy
        end
      end

      context 'H5 to H4 when no pieces around' do
        subject(:piece) { described_class.new(:black, 'H5', board) }
        before do
          allow(board).to receive(:empty?).and_return(true)
        end

        it 'will return true' do
          result = piece.valid_move?('H4')
          expect(result).to be_truthy
        end
      end
    end
  end
end
