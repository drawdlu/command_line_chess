require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/rook'
require_relative '../lib/player'
require_relative '../lib/pieces/queen'
require_relative '../lib/pieces/pawn'
require_relative '../lib/pieces/bishop'
require_relative '../lib/pieces/knight'

describe Game do
  $stdout = File.open(File::NULL, 'w')
  let(:board) { Board.new }
  let(:player) { Player.new(:white) }
  subject(:game) { described_class.new(board, player) }
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

    context 'when in checkmate where opponents control all moves including King taking a piece' do
      let(:pieces) do
        [{ color: :black, position: 'E8', class: King },
         { color: :black, position: 'D8', class: Queen },
         { color: :black, position: 'D7', class: Pawn },
         { color: :white, position: 'F7', class: Queen },
         { color: :white, position: 'C4', class: Bishop }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:black) }
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return True' do
        result = game.send(:checkmate?)
        expect(result).to be_truthy
      end
    end

    context 'when not in checkmate' do
      let(:pieces) do
        [{ color: :black, position: 'B6', class: Rook },
         { color: :black, position: 'D7', class: King },
         { color: :black, position: 'D6', class: Pawn },
         { color: :black, position: 'C5', class: Pawn },
         { color: :black, position: 'B4', class: Pawn },
         { color: :black, position: 'F5', class: Bishop },
         { color: :white, position: 'D5', class: Pawn },
         { color: :white, position: 'C4', class: Pawn },
         { color: :white, position: 'C7', class: Rook }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:black) }
      before do
        rook = dummy_board.board[1][2]
        game.instance_variable_set(:@opponent_pieces_in_check, [rook])
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return False' do
        result = game.send(:checkmate?)
        expect(result).to be_falsy
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
      it 'will return {class: Pawn, piece_position: nil, take: false, position: B2}' do
        result = game.send(:extract_data, 'b2')
        filtered = { class: Pawn, piece_position: nil, take: false, position: 'B2' }
        expect(result).to eq(filtered)
      end
    end

    context 'when Na3 is entered' do
      it 'will return {class: Knight, piece_position: nil, take: false, position: A3}' do
        result = game.send(:extract_data, 'Na3')
        filtered = { class: Knight, piece_position: nil, take: false, position: 'A3' }
        expect(result).to eq(filtered)
      end
    end

    context 'when dxc3 is entered' do
      it 'will return {class: Pawn, piece_position: d, take: true, position: C3}' do
        result = game.send(:extract_data, 'dxc3')
        filtered = { class: Pawn, piece_position: 'D', take: true, position: 'C3' }
        expect(result).to eq(filtered)
      end
    end

    context 'when R4d8 is entered' do
      it 'will return {class: Rook, piece_position: 4, take: true, position: D8}' do
        result = game.send(:extract_data, 'R4d8')
        filtered = { class: Rook, piece_position: '4', take: false, position: 'D8' }
        expect(result).to eq(filtered)
      end
    end

    context 'when Ncxe5 is entered' do
      it 'will return {class: Knight, piece_position: c, take: true, position: E5}' do
        result = game.send(:extract_data, 'Ncxe5')
        filtered = { class: Knight, piece_position: 'C', take: true, position: 'E5' }
        expect(result).to eq(filtered)
      end
    end
  end

  describe '#piece_with_move' do
    let(:board) { Board.new }
    context 'when { class: Pawn, piece_position: nil, take: false, position: C3 }' do
      before do
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      it 'will return Pawn at C2' do
        move_data = { class: Pawn, piece_position: nil, take: false, position: 'C3' }
        result = game.send(:piece_with_move, move_data)
        pawn = result.instance_of?(Pawn)
        position = result.current_position
        expect(pawn).to be_truthy
        expect(position).to eq('C2')
      end
    end

    context 'when { class: Knight, piece_position: nil, take: false, position: A3 }' do
      before do
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      it 'will return Knight at B1' do
        move_data = { class: Knight, piece_position: nil, take: false, position: 'A3' }
        result = game.send(:piece_with_move, move_data)
        pawn = result.instance_of?(Knight)
        position = result.current_position
        expect(pawn).to be_truthy
        expect(position).to eq('B1')
      end
    end
  end

  describe '#valid_move?' do
    let(:board) { Board.new }
    context 'when Na3' do
      before do
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      it 'will return true' do
        result = game.send(:valid_move?, 'Na3')
        expect(result).to be_truthy
      end
    end

    context 'when h3' do
      before do
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      it 'will return true' do
        result = game.send(:valid_move?, 'h3')
        expect(result).to be_truthy
      end
    end

    context 'when e5' do
      before do
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      it 'will return false' do
        result = game.send(:valid_move?, 'e5')
        expect(result).to be_falsy
      end
    end

    context 'when a3' do
      before do
        board.update_valid_moves
        game.instance_variable_set(:@board, board)
      end
      it 'will return true' do
        result = game.send(:valid_move?, 'a3')
        expect(result).to be_truthy
      end
    end

    context 'move a Queen to take Knight in check Qxc7' do
      let(:pieces) do
        [{ color: :black, position: 'E8', class: King },
         { color: :black, position: 'D8', class: Queen },
         { color: :white, position: 'C7', class: Knight }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:black) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return true' do
        result = game.send(:valid_move?, 'Qxc7')
        expect(result).to be_truthy
      end
    end

    context 'Kxd2 moving a King to take Bishop where a Rook can get to King' do
      let(:pieces) do
        [{ color: :black, position: 'A2', class: Rook },
         { color: :black, position: 'D2', class: Bishop },
         { color: :white, position: 'E1', class: King },
         { color: :white, position: 'D1', class: Queen }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:white) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return false' do
        result = game.send(:valid_move?, 'Kxd2')
        expect(result).to be_falsy
      end
    end

    context 'Kxd2 moving a King to take Bishop where a Bishop can get to King' do
      let(:pieces) do
        [{ color: :black, position: 'A5', class: Bishop },
         { color: :black, position: 'D2', class: Bishop },
         { color: :white, position: 'E1', class: King },
         { color: :white, position: 'D1', class: Queen }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:white) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return false' do
        result = game.send(:valid_move?, 'Kxd2')
        expect(result).to be_falsy
      end
    end

    context 'Kxd2 moving a King to take Bishop where a Queen can get to King' do
      let(:pieces) do
        [{ color: :black, position: 'D8', class: Queen },
         { color: :black, position: 'D2', class: Bishop },
         { color: :white, position: 'E1', class: King },
         { color: :white, position: 'D1', class: Queen }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:white) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return false' do
        result = game.send(:valid_move?, 'Kxd2')
        expect(result).to be_falsy
      end
    end

    context 'Kxd2 moving a King to take Bishop where a Pawn can get to King' do
      let(:pieces) do
        [{ color: :black, position: 'C3', class: Pawn },
         { color: :black, position: 'D2', class: Bishop },
         { color: :white, position: 'E1', class: King },
         { color: :white, position: 'D1', class: Queen }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:white) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return false' do
        result = game.send(:valid_move?, 'Kxd2')
        expect(result).to be_falsy
      end
    end

    context 'Kxd2 moving a King to take Bishop where a Knight can get to King' do
      let(:pieces) do
        [{ color: :black, position: 'B1', class: Knight },
         { color: :black, position: 'D2', class: Bishop },
         { color: :white, position: 'E1', class: King },
         { color: :white, position: 'D1', class: Queen }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:white) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return false' do
        result = game.send(:valid_move?, 'Kxd2')
        expect(result).to be_falsy
      end
    end

    context 'Kxd2 moving a King to take Bishop where a King can get to King' do
      let(:pieces) do
        [{ color: :black, position: 'C2', class: King },
         { color: :black, position: 'D2', class: Bishop },
         { color: :white, position: 'E1', class: King },
         { color: :white, position: 'D1', class: Queen }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:white) }

      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return false' do
        result = game.send(:valid_move?, 'Kxd2')
        expect(result).to be_falsy
      end
    end

    context 'testing when only King can move' do
      let(:pieces) do
        [{ color: :black, position: 'E6', class: King },
         { color: :black, position: 'G5', class: Pawn },
         { color: :white, position: 'A5', class: Bishop },
         { color: :white, position: 'D1', class: Rook },
         { color: :white, position: 'G1', class: Pawn },
         { color: :white, position: 'F8', class: Queen },
         { color: :white, position: 'F3', class: King }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:black) }
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end

      it 'will return true for valid moves' do
        result = game.valid_move?('Ke5')
        board = game.instance_variable_get(:@board)
        king = board.board[2][4]
        puts king.valid_moves
        expect(result).to be_truthy
      end
    end
  end

  describe '#valid_castling?' do
    let(:pieces) do
      [{ color: :white, position: 'E1', class: King },
       { color: :white, position: 'H1', class: Rook },
       { color: :white, position: 'A1', class: Knight }]
    end
    let(:dummy_board) { create_dummy(pieces) }
    let(:active_player) { Player.new(:white) }
    context 'when king side and both pieces has not moved' do
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return true' do
        result = game.send(:valid_castling?, '0-0')
        expect(result).to be_truthy
      end
    end

    context 'when queen side and knight is in A1' do
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return false' do
        result = game.send(:valid_castling?, '0-0-0')
        expect(result).to be_falsy
      end
    end

    context 'when king side and rook has moved but still in H1' do
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return false' do
        rook = dummy_board.board[7][7]
        rook.instance_variable_set(:@moved, true)
        result = game.send(:valid_castling?, '0-0-0')
        expect(result).to be_falsy
      end
    end
  end

  describe '#opponent_controls_king_moves?' do
    context 'when in checkmate where opponents control all moves including King taking a piece' do
      let(:pieces) do
        [{ color: :black, position: 'E8', class: King },
         { color: :black, position: 'D8', class: Queen },
         { color: :black, position: 'D7', class: Pawn },
         { color: :white, position: 'F7', class: Queen },
         { color: :white, position: 'C4', class: Bishop }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:black) }
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return True' do
        result = game.send(:opponent_controls_king_moves?)
        expect(result).to be_truthy
      end
    end

    context 'when in checkmate where opponents control all moves including King taking a piece' do
      let(:pieces) do
        [{ color: :black, position: 'E8', class: King },
         { color: :black, position: 'D8', class: Queen },
         { color: :black, position: 'D7', class: Pawn },
         { color: :white, position: 'F7', class: Queen },
         { color: :white, position: 'C4', class: Bishop }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      let(:active_player) { Player.new(:black) }
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return True' do
        result = game.send(:opponent_controls_king_moves?)
        expect(result).to be_truthy
      end
    end
  end

  describe '#will_result_in_check?' do
    let(:pieces) do
      [{ color: :white, position: 'A1', class: King },
       { color: :black, position: 'C3', class: Pawn }]
    end
    let(:dummy_board) { create_dummy(pieces) }
    let(:active_player) { Player.new(:white) }
    context 'when a move will result in check' do
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return true' do
        board = game.instance_variable_get(:@board)
        king = board.board[7][0]
        result = game.send(:will_result_in_check?, king, 'B2')
        expect(result).to be_truthy
      end
    end

    context 'when a move will not result in check' do
      before do
        game.instance_variable_set(:@board, dummy_board)
        game.instance_variable_set(:@active_player, active_player)
      end
      it 'will return false' do
        board = game.instance_variable_get(:@board)
        king = board.board[7][0]
        result = game.send(:will_result_in_check?, king, 'A2')
        expect(result).to be_falsy
      end
    end
  end
end
