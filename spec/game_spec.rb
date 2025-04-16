require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/king'
require_relative '../lib/rook'
require_relative '../lib/player'
require_relative '../lib/queen'
require_relative '../lib/pawn'

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

  describe '#stalemate?' do
    $stdout = File.open(File::NULL, 'w')
    new_board = Board.new
    rook1 = Rook.new(:black, 'A2', new_board)
    queen = Queen.new(:black, 'D4', new_board)
    rook2 = Rook.new(:black, 'F4', new_board)
    king = King.new(:white, 'E1', new_board)
    pawn_black = Pawn.new(:black, 'H4', new_board)
    black_pieces = Set[]
    black_pieces.add(rook1)
    black_pieces.add(rook2)
    black_pieces.add(queen)
    black_pieces.add(pawn_black)
    white_pieces = Set[]
    white_pieces.add(king)
    new_board.instance_variable_set(:@board, Array.new(8) { Array.new(8, nil) })
    new_board.board[0][7] = rook1
    new_board.board[4][3] = queen
    new_board.board[4][4] = rook2
    new_board.board[7][4] = king

    new_board.board[4][7] = pawn_black
    black_pieces.each do |piece|
      piece.change_valid_moves
    end
    new_board.instance_variable_set(:@black_pieces, black_pieces)

    context 'when it is a stalemate' do
      before do
        pawn_white = Pawn.new(:white, 'H3', new_board)
        new_board.board[5][7] = pawn_white
        white_pieces.add(pawn_white)
        white_pieces.each do |piece|
          piece.change_valid_moves
        end
        new_board.instance_variable_set(:@white_pieces, white_pieces)
        game.instance_variable_set(:@board, new_board)
      end

      it 'returns True' do
        result = game.send(:stalemate?)
        expect(result).to be_truthy
      end
    end

    context 'when it is not a stalemate because a piece can still move' do
      before do
        pawn_white = Pawn.new(:white, 'H2', new_board)
        white_pieces.delete(Pawn)
        new_board.board[6][7] = pawn_white
        new_board.board[5][7] = nil
        white_pieces.delete_if { |piece| piece.instance_of?(Pawn) }
        white_pieces.add(pawn_white)
        white_pieces.each do |piece|
          piece.change_valid_moves
        end
        new_board.instance_variable_set(:@white_pieces, white_pieces)
        game.instance_variable_set(:@board, new_board)
      end

      it 'returns False' do
        result = game.send(:stalemate?)
        expect(result).to be_falsy
      end
    end
  end
end
