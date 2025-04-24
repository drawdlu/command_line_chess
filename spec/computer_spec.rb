# frozen_string_literal: true

require_relative '../lib/computer'
require_relative '../lib/board'
require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/pieces/queen'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/knight'

describe Computer do
  let(:board) { Board.new }
  let(:game) { instance_double(Game) }
  subject(:computer) { described_class.new(game, :white) }

  describe '#convert_to_notation' do
    context 'when Pawn to A3 is entered' do
      before do
        game.instance_variable_set(:@board, board)
        allow(game).to receive(:board).and_return(board)
      end
      it 'will return a3' do
        board = game.instance_variable_get(:@board)
        piece = board.board[6][0]
        move = 'A3'
        result = computer.convert_to_notation(piece, move)
        expect(result).to eq('a3')
      end
    end

    context 'when Knight to A3 is entered' do
      before do
        game.instance_variable_set(:@board, board)
        allow(game).to receive(:board).and_return(board)
      end
      it 'will return Nba3' do
        board = game.instance_variable_get(:@board)
        piece = board.board[7][1]
        move = 'A3'
        result = computer.convert_to_notation(piece, move)
        expect(result).to eq('Nba3')
      end
    end

    context 'when Knight to F3 is entered' do
      before do
        game.instance_variable_set(:@board, board)
        allow(game).to receive(:board).and_return(board)
      end

      it 'will return a3' do
        board = game.instance_variable_get(:@board)
        piece = board.board[7][6]
        move = 'F3'
        result = computer.convert_to_notation(piece, move)
        expect(result).to eq('Ngf3')
      end
    end
  end

  describe '#pick_random_move' do
    let(:move) { computer.pick_random_move }

    before do
      board.update_valid_moves
      allow(game).to receive(:board).and_return(board)
      allow(game).to receive(:valid_move?).and_return(true)
    end

    it 'will return a random move from available black moves' do
      valid_notation = computer.valid_code?(move)
      expect(valid_notation).to be_truthy
    end
  end
end
