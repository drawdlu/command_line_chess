# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'

describe Pawn do
  let(:board) { instance_double(Board) }
  subject(:pawn) { described_class.new(:white, 'B5', board) }

  describe '#opponent_double_move?' do
    context 'when last move is A7 to A5 opponent pawn' do
      let(:opponent_pawn) { Pawn.new(:black, 'A5', board) }
      before do
        last_move = { from: 'A7', to: 'A5', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'will return True' do
        result = pawn.send(:opponent_double_move?)
        expect(result).to be_truthy
      end
    end

    context 'when last move is A7 to A6 opponent pawn' do
      let(:opponent_pawn) { Pawn.new(:black, 'A6', board) }
      before do
        last_move = { from: 'A7', to: 'A6', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'will return False' do
        result = pawn.send(:opponent_double_move?)
        expect(result).to be_falsy
      end
    end
  end
end
