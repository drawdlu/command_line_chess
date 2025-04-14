require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/king'
require_relative '../lib/rook'
require_relative '../lib/player'

describe Game do
  subject(:game) { described_class.new }
  describe '#valid_position?' do
    context 'when A8 is entered' do
      it 'returns True' do
        result = game.send(:valid_position?, 'A8')
        expect(result).to be_truthy
      end
    end

    context 'when E4 is entered' do
      it 'returns True' do
        result = game.send(:valid_position?, 'E4')
        expect(result).to be_truthy
      end
    end

    context 'when I6 is entered' do
      it 'returns False' do
        result = game.send(:valid_position?, 'I6')
        expect(result).to be_falsy
      end
    end

    context 'when G9 is entered' do
      it 'returns False' do
        result = game.send(:valid_position?, 'G9')
        expect(result).to be_falsy
      end
    end
  end

  describe '#get_from_set' do
    let(:board) { instance_double(Board) }
    let(:king) { King.new(:white, 'E1', board) }
    context 'when a set with King is passed in' do
      it 'will return the King in set' do
        set_pieces = Set[]
        set_pieces.add(king)
        result = game.send(:get_from_set, set_pieces, King)
        expect(result).to eq(king)
      end
    end
  end

  describe '#check?' do
    context 'when opponent pieces have control of King square' do
      let(:player) { instance_double(Player) }
      before do
        new_board = game.instance_variable_get(:@board)
        rook = Rook.new(:black, 'E5', new_board)
        new_board.board[6][4] = nil
        new_board.board[3][4] = rook
        rook.instance_variable_set(:@board, new_board)
        rook.change_valid_moves
        new_board.black_pieces.add(rook)
        game.instance_variable_set(:@active_player, player)
        game.instance_variable_set(:@board, new_board)
        allow(player).to receive(:color).and_return(:white)
      end

      it 'returns True' do
        result = game.send(:check?)
        expect(result).to be_truthy
      end
    end
  end
end
