# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../lib/board'

describe Rook do
  let(:board) { instance_double(Board) }

  describe '#all_valid_moves' do
    subject(:rook) { described_class.new(:white, 'A1', Board.new) }
    context 'when at A1 position on board and no pieces moved yet' do
      it 'returns empty Set' do
        result = rook.all_valid_moves
        expect(result).to be_empty
      end
    end

    context 'when A2 is empty and ally in A3' do
      let(:ally) { Rook.new(:white, 'A3', board) }

      it 'returns Set[A2]' do
        new_board = rook.instance_variable_get(:@board)
        new_board.board[6][0] = nil
        new_board.board[5][0] = ally
        rook.instance_variable_set(:@board, new_board)
        result = rook.all_valid_moves
        expect(result).to eq(Set['A2'])
      end
    end

    context 'when A2 is empty and opponent in A3' do
      let(:opponent) { Rook.new(:black, 'A3', board) }

      it 'returns Set[A2, A3]' do
        new_board = rook.instance_variable_get(:@board)
        new_board.board[6][0] = nil
        new_board.board[5][0] = opponent
        rook.instance_variable_set(:@board, new_board)
        result = rook.all_valid_moves
        expect(result).to eq(Set['A2', 'A3'])
      end
    end
  end
end
