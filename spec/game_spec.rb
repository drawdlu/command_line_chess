require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/king'
require_relative '../lib/rook'
require_relative '../lib/player'
require_relative '../lib/queen'
require_relative '../lib/pawn'
require_relative '../lib/bishop'
require_relative '../lib/knight'

describe Game do
  $stdout = File.open(File::NULL, 'w')
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

  describe 'moving during a Check' do
    let(:pieces) do
      [{ color: :white, position: 'E1', class: King },
       { color: :white, position: 'H2', class: Rook, moved: true },
       { color: :white, position: 'A6', class: Rook, moved: true },
       { color: :white, position: 'B4', class: Queen },
       { color: :black, position: 'E6', class: Rook, moved: true }]
    end
    let(:board) { create_dummy(pieces) }
    let(:king_position) { 'E1' }
    let(:protect_rook) { 'H2' }
    let(:eat_rook) { 'A6' }
    let(:queen) { 'B4' }
    let(:active_player) { Player.new(:white) }

    describe '#valid_start?' do
      context 'when in check moving King' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'will accept King position when it has a move not controlled by opponent' do
          result = game.send(:valid_start?, king_position)
          expect(result).to be_truthy
        end
      end

      context 'when in check moving Rook to protect' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'will accept Rook given that it can protect King' do
          result = game.send(:valid_start?, protect_rook)
          expect(result).to be_truthy
        end
      end

      context 'when in check moving Rook to eat Piece' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'will accept Rook position given that it can take opponent that has check on King' do
          result = game.send(:valid_start?, eat_rook)
          expect(result).to be_truthy
        end
      end

      context 'when in check moving Queen that can cover path to King' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'will accept Queen' do
          result = game.send(:valid_start?, queen)
          expect(result).to be_truthy
        end
      end

      context 'when trying to move King that cant be moved on check' do
        let(:pieces) do
          [{ color: :white, position: 'A6', class: Rook },
           { color: :white, position: 'H2', class: Rook },
           { color: :white, position: 'B1', class: King },
           { color: :black, position: 'B6', class: Rook },
           { color: :black, position: 'C6', class: Queen },
           { color: :black, position: 'E5', class: Bishop },
           { color: :black, position: 'A3', class: Rook }]
        end
        let(:board) { create_dummy(pieces) }
        before do
          opponent = board.board[2][1]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end
        it 'will return false' do
          king_position = 'B1'
          result = game.send(:valid_start?, king_position)
          expect(result).to be_falsy
        end
      end

      context 'moving King not in check but all moves of King controlled by opponent' do
        let(:pieces) do
          [{ color: :white, position: 'A6', class: Rook },
           { color: :white, position: 'B1', class: King },
           { color: :black, position: 'G2', class: Rook },
           { color: :black, position: 'C6', class: Queen },
           { color: :black, position: 'E5', class: Bishop },
           { color: :black, position: 'A3', class: Rook }]
        end
        let(:board) { create_dummy(pieces) }
        before do
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@active_player, active_player)
        end
        it 'will return false' do
          king_position = 'B1'
          result = game.send(:valid_start?, king_position)
          expect(result).to be_falsy
        end
      end
    end

    describe '#valid_move_position?' do
      context 'when moving King out of opponent control' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'returns True' do
          king = board.board[7][4]
          result = game.send(:valid_move_position?, king, 'D1')
          expect(result).to be_truthy
        end
      end

      context 'when protecting King' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'returns True' do
          rook = board.board[6][7]
          result = game.send(:valid_move_position?, rook, 'E2')
          expect(result).to be_truthy
        end
      end

      context 'when taking opponent in that has check on King' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'returns True' do
          rook = board.board[2][0]
          result = game.send(:valid_move_position?, rook, 'E6')
          expect(result).to be_truthy
        end
      end

      context 'when just moving without protecting or taking' do
        before do
          opponent = board.board[2][4]
          game.instance_variable_set(:@board, board)
          game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
          game.instance_variable_set(:@active_player, active_player)
        end

        it 'returns False' do
          rook = board.board[2][0]
          result = game.send(:valid_move_position?, rook, 'D6')
          expect(result).to be_falsy
        end
      end
    end
  end

  describe '#checkmate?' do
    let(:active_player) { Player.new(:white) }

    context 'when it is not checkmate' do
      let(:pieces) do
        [{ color: :white, position: 'A6', class: Rook },
         { color: :white, position: 'H2', class: Rook },
         { color: :white, position: 'B1', class: King },
         { color: :black, position: 'B6', class: Rook },
         { color: :black, position: 'C6', class: Queen },
         { color: :black, position: 'E5', class: Bishop },
         { color: :black, position: 'A3', class: Rook }]
      end
      let(:board) { create_dummy(pieces) }
      before do
        opponent = board.board[2][1]
        game.instance_variable_set(:@board, board)
        game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return False' do
        result = game.send(:checkmate?)
        expect(result).to be_falsy
      end
    end

    context 'when it is checkmate' do
      let(:pieces) do
        [{ color: :white, position: 'D6', class: Rook },
         { color: :white, position: 'E1', class: Rook },
         { color: :white, position: 'B1', class: King },
         { color: :black, position: 'B6', class: Rook },
         { color: :black, position: 'C6', class: Queen },
         { color: :black, position: 'E5', class: Bishop },
         { color: :black, position: 'A3', class: Rook }]
      end
      let(:board) { create_dummy(pieces) }
      before do
        opponent = board.board[2][1]
        game.instance_variable_set(:@board, board)
        game.instance_variable_set(:@opponent_pieces_in_check, [opponent])
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return True' do
        result = game.send(:checkmate?)
        expect(result).to be_truthy
      end
    end
  end

  describe '#valid_code?' do
    context 'when Re5 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'Re5')
        expect(result).to be_truthy
      end
    end

    context 'when Ge5 is entered' do
      it 'returns False' do
        result = game.send(:valid_code?, 'Ge5')
        expect(result).to be_falsy
      end
    end

    context 'when g4 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'g4')
        expect(result).to be_truthy
      end
    end

    context 'when Rxd5 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'Rxd5')
        expect(result).to be_truthy
      end
    end

    context 'when Rdd5 is entered' do
      it 'returns False' do
        result = game.send(:valid_code?, 'Rdd5')
        expect(result).to be_falsy
      end
    end

    context 'when R4d8 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'R4d8')
        expect(result).to be_truthy
      end
    end

    context 'when Bdf4 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'Bdf4')
        expect(result).to be_truthy
      end
    end

    context 'when R4xd8 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'R4xd8')
        expect(result).to be_truthy
      end
    end

    context 'when Ncxe5 is entered' do
      it 'returns True' do
        result = game.send(:valid_code?, 'Ncxe5')
        expect(result).to be_truthy
      end
    end

    context 'when Nexe5 is entered' do
      it 'returns False' do
        result = game.send(:valid_code?, 'Nexe5')
        expect(result).to be_falsy
      end
    end
  end

  describe '#filter_move' do
    context 'when b2 is entered' do
      it 'will return {class: Pawn, piece_position: nil, take: false, position: b2}' do
        result = game.send(:extract_data, 'b2')
        filtered = { class: Pawn, piece_position: nil, take: false, position: 'b2' }
        expect(result).to eq(filtered)
      end
    end

    context 'when Na3 is entered' do
      it 'will return {class: Knight, piece_position: nil, take: false, position: a3}' do
        result = game.send(:extract_data, 'Na3')
        filtered = { class: Knight, piece_position: nil, take: false, position: 'a3' }
        expect(result).to eq(filtered)
      end
    end

    context 'when dxc3 is entered' do
      it 'will return {class: Pawn, piece_position: d, take: true, position: c3}' do
        result = game.send(:extract_data, 'dxc3')
        filtered = { class: Pawn, piece_position: 'd', take: true, position: 'c3' }
        expect(result).to eq(filtered)
      end
    end

    context 'when R4d8 is entered' do
      it 'will return {class: Rook, piece_position: 4, take: true, position: c3}' do
        result = game.send(:extract_data, 'R4d8')
        filtered = { class: Rook, piece_position: '4', take: false, position: 'd8' }
        expect(result).to eq(filtered)
      end
    end

    context 'when Ncxe5 is entered' do
      it 'will return {class: Knight, piece_position: c, take: true, position: e5}' do
        result = game.send(:extract_data, 'Ncxe5')
        filtered = { class: Knight, piece_position: 'c', take: true, position: 'e5' }
        expect(result).to eq(filtered)
      end
    end
  end

  describe '#piece_with_move' do
    context 'when Na3' do
      before do
        board = Board.new
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      xit 'will return Knight at B1' do
        result = game.send(:piece_with_move, 'Na3')
        knight = result.instance_of?(Knight)
        position = result.current_position
        expect(knight).to be_truthy
        expect(position).to eq('B1')
      end
    end
  end
end
