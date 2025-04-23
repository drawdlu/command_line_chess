# frozen_string_literal: true

require_relative '../lib/computer'
require_relative '../lib/board'
require_relative '../lib/game'

describe Computer do
  let(:board) { Board.new }
  let(:game) { instance_double(Game) }
  subject(:computer) { described_class.new(board, game) }

  describe '#convert_to_notation' do
    context 'when Pawn to A3 is entered' do
      it 'will return a3' do
        board = computer.instance_variable_get(:@board)
        piece = board.board[6][0]
        move = 'A3'
        result = computer.convert_to_notation(piece, move)
        expect(result).to eq('a3')
      end
    end

    context 'when Knight to A3 is entered' do
      it 'will return a3' do
        board = computer.instance_variable_get(:@board)
        piece = board.board[7][1]
        move = 'A3'
        result = computer.convert_to_notation(piece, move)
        expect(result).to eq('Na3')
      end
    end

    context 'when Knight to F3 is entered' do
      it 'will return a3' do
        board = computer.instance_variable_get(:@board)
        piece = board.board[7][6]
        move = 'F3'
        result = computer.convert_to_notation(piece, move)
        expect(result).to eq('Nf3')
      end
    end
  end

  describe '#pick_random_move' do
    let(:move) { computer.pick_random_move }

    before do
      board = computer.instance_variable_get(:@board)
      board.update_valid_moves
      allow(game).to receive(:valid_move?).and_return(true)
    end

    it 'will return a random move from available black moves' do
      valid_notation = computer.valid_code?(move)
      expect(valid_notation).to be_truthy
    end
  end
end
