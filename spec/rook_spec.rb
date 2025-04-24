# frozen_string_literal: true

require_relative '../lib/pieces/rook'
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

  describe '#castling' do
    let(:pieces) do
      [{ color: :white, position: 'E1', class: King },
       { color: :white, position: 'H1', class: Rook },
       { color: :white, position: 'A1', class: Rook }]
    end
    let(:board) { create_dummy(pieces) }

    context 'when rook and king has not moved, no opponents control space between' do
      it 'will return position of King E1' do
        right_rook = board.board[7][7]
        left_rook = board.board[7][0]
        right_result = right_rook.send(:castling)
        left_result = left_rook.send(:castling)
        king_position = Set['E1']
        expect(right_result).to eq(king_position)
        expect(left_result).to eq(king_position)
      end
    end

    context 'when only left rook has moved and king has not moved, no opponents control space between' do
      it 'will return position of King E1 for right only' do
        right_rook = board.board[7][7]
        left_rook = board.board[7][0]
        left_rook.instance_variable_set(:@moved, true)
        right_result = right_rook.send(:castling)
        left_result = left_rook.send(:castling)
        king_position = Set['E1']
        empty_set = Set[]
        expect(right_result).to eq(king_position)
        expect(left_result).to eq(empty_set)
      end
    end

    context 'king and rook not moved and an enemy is controlling left rook squares' do
      it 'will return King position for right rook only' do
        black_rook = Rook.new(:black, 'B7', board)
        insert_piece(black_rook)
        right_rook = board.board[7][7]
        left_rook = board.board[7][0]
        right_result = right_rook.send(:castling)
        left_result = left_rook.send(:castling)
        king_position = Set['E1']
        empty_set = Set[]
        expect(right_result).to eq(king_position)
        expect(left_result).to eq(empty_set)
      end
    end
  end
end
