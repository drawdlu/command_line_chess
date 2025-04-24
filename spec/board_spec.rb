require_relative '../lib/board'
require_relative '../lib/pawn'
require_relative '../lib/king'
require_relative '../lib/rook'

describe Board do
  subject(:board) { described_class.new }
  describe '#empty' do
    context 'when spot is empty' do
      it 'will return true' do
        result = board.empty?('A4')
        expect(result).to be_truthy
      end
    end

    context 'when spot is occupied' do
      it 'will return false' do
        sample_board = Array.new(8) { Array.new(8, nil) }
        # 0 is a place holder for some object value since it only checks for nil
        sample_board[3][4] = 0
        board.instance_variable_set(:@board, sample_board)
        result = board.empty?('E5')
        expect(result).to be_falsy
      end
    end
  end

  describe '#move_to' do
    context 'A2 to A4' do
      it 'moves A2 pawn to A4, sets A2 to nil, and does not update opponent list' do
        piece = board.board[6][0]
        board.move_to('A2', 'A4')
        piece_num = board.black_pieces.length
        expect(board.board[6][0]).to be_nil
        expect(board.board[4][0]).to eq(piece)
        expect(piece_num).to eq(16)
      end
    end

    context 'B1 to C3' do
      it 'moves B1 knight to C3, sets B1 to nil, and does not update opponent list' do
        piece = board.board[7][1]
        board.move_to('B1', 'C3')
        piece_num = board.black_pieces.length
        expect(board.board[7][1]).to be_nil
        expect(board.board[5][2]).to eq(piece)
        expect(piece_num).to eq(16)
      end
    end

    context 'B1 to C3 when a piece is in C3' do
      it 'removes C3 opponent from list moves B1 knight to C3 and sets B1 to nil' do
        board.board[5][2] = Pawn.new(:black, 'A1', board)
        piece = board.board[7][1]
        piece_to_remove = board.board[5][2]
        board.move_to('B1', 'C3')
        result = board.black_pieces.include?(piece_to_remove)
        expect(board.board[7][1]).to be_nil
        expect(board.board[5][2]).to eq(piece)
        expect(result).to be_falsy
      end
    end

    context 'C1 to H6 when an opponent is in H6' do
      it 'removes opponent H6 from list, moves C1 bishop to H6, and sets C1 to nil' do
        board.board[2][7] = Pawn.new(:black, 'A1', board)
        piece = board.board[7][2]
        piece_to_remove = board.board[2][7]
        board.move_to('C1', 'H6')
        result = board.black_pieces.include?(piece_to_remove)
        expect(board.board[7][2]).to be_nil
        expect(board.board[2][7]).to eq(piece)
        expect(result).to be_falsy
      end
    end
  end

  describe '#get_back_position' do
    context 'when B6 and :white' do
      let(:pawn) { Pawn.new(:white, 'C5', board) }
      it 'returns B5' do
        result = board.send(:get_back_position, pawn, 'B6')
        expect(result).to eq('B5')
      end
    end

    context 'when B6 and :black' do
      let(:pawn) { Pawn.new(:black, 'B7', board) }
      it 'returns B7' do
        result = board.send(:get_back_position, pawn, 'B6')
        expect(result).to eq('B7')
      end
    end
  end

  describe 'EN-PASSANT' do
    let(:pawn) { Pawn.new(:white, 'B5', board) }
    let(:opponent) { Pawn.new(:black, 'A5', board) }
    let(:ally) { Pawn.new(:white, 'A5', board) }

    # used for checking en passant, one condition is that final position is empty
    describe '#opponent_pawn_behind_final_position?' do
      context 'A5 is an opponent and final position is at A6' do
        before do
          new_board = board.instance_variable_get(:@board)
          new_board[3][0] = opponent
          board.instance_variable_set(:@new_board, new_board)
        end

        it 'returns True' do
          final_position = 'A6'
          result = board.send(:opponent_pawn_behind_final_position?, pawn, final_position)
          expect(result).to be_truthy
        end
      end

      context 'A5 is an ally and final position is at A6' do
        before do
          new_board = board.instance_variable_get(:@board)
          new_board[3][0] = ally
          board.instance_variable_set(:@new_board, new_board)
        end

        it 'returns False' do
          final_position = 'A6'
          result = board.send(:opponent_pawn_behind_final_position?, pawn, final_position)
          expect(result).to be_falsy
        end
      end

      context 'A5 is is empty and final position is at A6' do
        it 'returns False' do
          final_position = 'A6'
          result = board.send(:opponent_pawn_behind_final_position?, pawn, final_position)
          expect(result).to be_falsy
        end
      end
    end

    # NOTE: that allowing pawn to move en passant is handled in Pawn object
    describe '#move_is_en_passant?' do
      context 'when an opponent pawn is in A5 and pawn moves to A6' do
        before do
          new_board = board.instance_variable_get(:@board)
          new_board[3][0] = opponent
          board.instance_variable_set(:@new_board, new_board)
        end

        it 'returns True' do
          final_position = 'A6'
          result = board.send(:move_is_en_passant?, final_position, pawn)
          expect(result).to be_truthy
        end
      end

      context 'when A5 is empty and pawn moves to A6' do
        it 'returns False' do
          final_position = 'A6'
          result = board.send(:move_is_en_passant?, final_position, pawn)
          expect(result).to be_falsy
        end
      end
    end

    describe '#delete_piece' do
      context 'when piece to be deleted is at A5' do
        before do
          new_board = board.instance_variable_get(:@board)
          new_board[3][0] = opponent
          board.instance_variable_set(:@new_board, new_board)
        end

        it 'deletes that piece from board and calls remove_piece' do
          final_position = 'A6'
          expect(board).to receive(:remove_piece)
          board.send(:delete_piece, final_position, pawn)
          value = board.board[3][0]
          expect(value).to be_nil
        end
      end
    end
  end

  describe '#handle_castling_move' do
    let(:pieces) do
      [{ color: :white, position: 'A1', class: Rook },
       { color: :white, position: 'E1', class: King },
       { color: :white, position: 'H1', class: Rook }]
    end
    let(:board) { create_dummy(pieces) }
    context 'when positions are A1 and E1' do
      it 'will update board King C1, Rook D1 and update piece positions' do
        rook = board.board[7][0]
        king = board.board[7][4]
        board.handle_castling_move('A1', 'E1')
        king_in_position = board.board[7][2] == king
        rook_in_position = board.board[7][3] == rook
        rook_position = rook.current_position
        king_position = king.current_position
        expect(king_in_position).to be_truthy
        expect(rook_in_position).to be_truthy
        expect(king_position).to eq('C1')
        expect(rook_position).to eq('D1')
      end
    end

    context 'when positions are E1 and H1' do
      it 'will update board King G1, Rook F1 and update piece positions' do
        rook = board.board[7][7]
        king = board.board[7][4]
        board.handle_castling_move('E1', 'H1')
        king_in_position = board.board[7][6] == king
        rook_in_position = board.board[7][5] == rook
        rook_position = rook.current_position
        king_position = king.current_position
        expect(king_in_position).to be_truthy
        expect(rook_in_position).to be_truthy
        expect(king_position).to eq('G1')
        expect(rook_position).to eq('F1')
      end
    end
  end

  describe '#check?' do
    context 'when it is in check' do
      let(:pieces) do
        [{ color: :white, position: 'B2', class: King },
         { color: :black, position: 'C3', class: Pawn }]
      end
      let(:dummy_board) { create_dummy(pieces) }
      it 'will return false' do
        result = dummy_board.check?(:white)
        expect(result).to be_truthy
      end
    end
  end
end
