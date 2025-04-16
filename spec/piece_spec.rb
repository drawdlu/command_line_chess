require_relative '../lib/piece'
require_relative '../lib/board'
require_relative '../lib/rook'
require_relative '../lib/king'

describe Piece do
  let(:board) { instance_double(Board) }
  subject(:piece) { described_class.new(:white, 'A5', board) }

  describe '#move_pos' do
    context 'when A5 is passed and -1, 0 as direction' do
      it 'will return A6' do
        result = piece.send(:move_pos, 'A5', -1, 0)
        expect(result).to eq('A6')
      end
    end

    context 'when A5 is passed and 1, 0 as direction' do
      it 'will return A4' do
        result = piece.send(:move_pos, 'A5', 1, 0)
        expect(result).to eq('A4')
      end
    end

    context 'when A5 is passed and -1, 2 as direction' do
      it 'will return C4' do
        result = piece.send(:move_pos, 'A5', 1, 2)
        expect(result).to eq('C4')
      end
    end
  end

  describe '#no_pieces_on_path?' do
    subject(:piece) { described_class.new(:white, 'D3', board) }
    context 'D3 to D6 and no pieces are in path' do
      before do
        allow(board).to receive(:empty?).twice.and_return(true)
      end

      it 'returns True' do
        result = piece.send(:no_pieces_on_path?, 'D6')
        expect(result).to be_truthy
      end
    end

    context 'D3 to D4' do
      it 'returns True' do
        result = piece.send(:no_pieces_on_path?, 'D4')
        expect(result).to be_truthy
      end
    end

    context 'D3 to B3 and a piece is in C3' do
      before do
        allow(board).to receive(:empty?).with('C3').and_return(false)
      end
      it 'returns False' do
        result = piece.send(:no_pieces_on_path?, 'B3')
        expect(result).to be_falsy
      end
    end

    context 'D3 to D7 where a piece is in D6' do
      before do
        allow(board).to receive(:empty?).exactly(3).times.and_return(true, true, false)
      end
      it 'returns False' do
        result = piece.send(:no_pieces_on_path?, 'D7')
        expect(result).to be_falsy
      end
    end
  end

  describe '#update_position' do
    context 'updates current_position instance var' do
      it 'updates current_position of piece' do
        piece.update_position('A8')
        position = piece.instance_variable_get(:@current_position)
        expect(position).to eq('A8')
      end
    end
  end

  describe '#ally_of_class_has_not_moved?' do
    subject(:piece) { described_class.new(:white, 'E1', board) }
    let(:rook) { Rook }

    context 'when an ally Rook has not moved' do
      let(:rook_instance) { Rook.new(:white, 'H1', board) }

      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(piece).to receive(:get_piece).and_return(rook)
        allow(piece).to receive(:opponent?).and_return(false)
        allow(piece).to receive(:get_piece).and_return(rook_instance)
      end

      it 'will return true' do
        result = piece.send(:ally_of_class_has_not_moved?, 'A8', rook)
        expect(result).to be_truthy
      end
    end

    context 'when an ally Rook has moved' do
      let(:rook_instance) { Rook.new(:white, 'H1', board) }

      before do
        allow(board).to receive(:empty?).and_return(false)
        allow(piece).to receive(:get_piece).and_return(rook)
        allow(piece).to receive(:opponent?).and_return(false)
        allow(piece).to receive(:get_piece).and_return(rook_instance)
      end

      it 'will return false' do
        rook_instance.instance_variable_set(:@moved, true)
        result = piece.send(:ally_of_class_has_not_moved?, 'A8', rook)
        expect(result).to be_falsy
      end
    end
  end

  describe '#middle_opponent_controlled?' do
    context 'if one of mid squares is controlled by an opponent piece' do
      let(:white_king) { King.new(:white, 'E1', board) }

      before do
        new_board = Board.new
        new_board.instance_variable_set(:@board, Array.new(8) { Array.new(8, nil) })
        white_rook = Rook.new(:white, 'H1', new_board)
        black_rook = Rook.new(:black, 'G7', new_board)
        new_board.board[7][7] = white_rook
        new_board.board[7][4] = white_king
        new_board.board[1][6] = black_rook
        black_rook.change_valid_moves
        black_pieces = Set[black_rook]
        new_board.instance_variable_set(:@black_pieces, black_pieces)
        white_king.instance_variable_set(:@board, new_board)
      end

      it 'will return true' do
        result = white_king.send(:middle_opponent_controlled?, 'H1')
        expect(result).to be_truthy
      end
    end

    context 'if one of mid squares is controlled by an opponent piece' do
      let(:white_king) { King.new(:white, 'E1', board) }

      before do
        new_board = Board.new
        new_board.instance_variable_set(:@board, Array.new(8) { Array.new(8, nil) })
        white_rook = Rook.new(:white, 'H1', new_board)
        black_rook = Rook.new(:black, 'B7', new_board)
        new_board.board[7][7] = white_rook
        new_board.board[7][4] = white_king
        new_board.board[1][2] = black_rook
        black_rook.change_valid_moves
        black_pieces = Set[black_rook]
        new_board.instance_variable_set(:@black_pieces, black_pieces)
        white_king.instance_variable_set(:@board, new_board)
      end

      it 'will return false' do
        result = white_king.send(:middle_opponent_controlled?, 'H1')
        expect(result).to be_falsy
      end
    end
  end
end
