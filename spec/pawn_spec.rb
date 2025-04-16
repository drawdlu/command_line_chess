# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../lib/board'
require_relative '../lib/queen'

describe Pawn do
  let(:board) { instance_double(Board) }
  subject(:pawn) { described_class.new(:white, 'B5', board) }

  describe '#opponent_double_move?' do
    context 'when last move is A7 to A5 opponent pawn' do
      let(:opponent_pawn) { Pawn.new(:black, 'A5', board) }
      before do
        last_move = { from: 'A7', to: 'A5', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'will return True' do
        result = pawn.send(:opponent_double_move?)
        expect(result).to be_truthy
      end
    end

    context 'when last move is A7 to A6 opponent pawn' do
      let(:opponent_pawn) { Pawn.new(:black, 'A6', board) }
      before do
        last_move = { from: 'A7', to: 'A6', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'will return False' do
        result = pawn.send(:opponent_double_move?)
        expect(result).to be_falsy
      end
    end
  end

  describe '#on_left_or_right?' do
    context 'B5 when opponent last move is on A5' do
      let(:opponent_pawn) { Pawn.new(:black, 'A5', board) }
      before do
        last_move = { from: 'A7', to: 'A5', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'returns True' do
        result = pawn.send(:on_left_or_right?)
        expect(result).to be_truthy
      end
    end

    context 'B5 when opponent is on A6' do
      let(:opponent_pawn) { Pawn.new(:black, 'A6', board) }
      before do
        last_move = { from: 'A7', to: 'A6', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'will return False' do
        result = pawn.send(:on_left_or_right?)
        expect(result).to be_falsy
      end
    end

    context 'B5 when opponent is on D5' do
      let(:opponent_pawn) { Pawn.new(:black, 'D5', board) }
      before do
        last_move = { from: 'D7', to: 'D5', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end

      it 'will return False' do
        result = pawn.send(:on_left_or_right?)
        expect(result).to be_falsy
      end
    end
  end

  describe 'en_passant' do
    context 'B5 when opponent double moves at A5' do
      let(:opponent_pawn) { Pawn.new(:black, 'A5', board) }
      before do
        last_move = { from: 'A7', to: 'A5', piece: opponent_pawn }
        allow(board).to receive(:last_move).and_return(last_move)
      end
      it 'will return Set[A6]' do
        result = pawn.send(:en_passant)
        expect(result).to eq(Set['A6'])
      end
    end
  end

  describe '#last_row?' do
    context 'if :white pawn is on A8' do
      subject(:white_pawn) { described_class.new(:white, 'A8', board) }
      it 'returns True' do
        result = white_pawn.send(:last_row?)
        expect(result).to be_truthy
      end
    end

    context 'if :black pawn is on E1' do
      subject(:black_pawn) { described_class.new(:black, 'E1', board) }
      it 'returns True' do
        result = black_pawn.send(:last_row?)
        expect(result).to be_truthy
      end
    end

    context 'if :black pawn is on E2' do
      subject(:black_pawn) { described_class.new(:black, 'E2', board) }
      it 'returns False' do
        result = black_pawn.send(:last_row?)
        expect(result).to be_falsy
      end
    end
  end

  describe '#create_piece_with_valid_moves' do
    context 'when piece is queen and pawn is :white, D8' do
      subject(:pawn) { described_class.new(:white, 'D8', board) }
      let(:queen) { class_double(Queen) }
      let(:new_queen) { Queen.new(pawn.color, pawn.current_position, board) }
      before do
        allow(queen).to receive(:new).and_return(new_queen)
        allow(board).to receive(:empty?).and_return(true)
      end
      it 'returns queen with same properties' do
        result = pawn.send(:create_piece_with_valid_moves, queen)
        expect(result).to eq(new_queen)
      end
    end
  end

  describe '#put_piece_on_board' do
    context 'when current pawn position is at A8' do
      subject(:pawn) { described_class.new(:white, 'A8', board) }
      let(:queen) { instance_double(Queen) }
      before do
        new_board = Board.new
        empty_board = Array.new(8) { Array.new(8, nil) }
        new_board.instance_variable_set(:@board, empty_board)
        empty_set = Set[]
        new_board.instance_variable_set(:@white_pieces, Set[pawn])
        new_board.instance_variable_set(:@black_pieces, empty_set)
        pawn.instance_variable_set(:@board, new_board)
        allow(queen).to receive(:current_position).and_return(pawn.current_position)
      end
      it 'will update board, add queen to board pieces, and remove pawn from pieces' do
        pawn.send(:put_piece_on_board, queen)
        pawn_index = { x: 0, y: 0 }
        pawn_board = pawn.instance_variable_get(:@board)
        square = pawn_board.board[pawn_index[:x]][pawn_index[:y]]
        pawn_in_list = pawn_board.white_pieces.include?(pawn)
        queen_in_list = pawn_board.white_pieces.include?(queen)
        expect(square).to eq(queen)
        expect(pawn_in_list).to be_falsy
        expect(queen_in_list).to be_truthy
      end
    end
  end

  describe '#prompt_for_promote_piece' do
    $stdout = File.open(File::NULL, 'w')
    context 'when knight is entered' do
      let(:knight) { 'knight' }

      before do
        allow(pawn).to receive(:gets).and_return(knight)
      end

      it 'will return KNIGHT' do
        result = pawn.send(:prompt_for_promote_piece)
        expect(result).to eq(knight.upcase)
      end
    end

    context 'when wrong prompt is entered once then knig is entered' do
      let(:knight) { 'knig' }

      before do
        allow(pawn).to receive(:gets).and_return('king', knight)
      end

      it 'will return KNIG' do
        result = pawn.send(:prompt_for_promote_piece)
        expect(result).to eq(knight.upcase)
      end
    end
  end

  describe '#convert_to_class' do
    context 'when input is "KNIGHT" ' do
      let(:knight) { Knight }
      it 'returns Knight class' do
        input = 'KNIGHT'
        result = pawn.send(:convert_to_class, input)
        expect(result).to eq(knight)
      end
    end

    context 'when input is "QUE" ' do
      let(:queen) { Queen }
      it 'returns Queen class' do
        input = 'QUE'
        result = pawn.send(:convert_to_class, input)
        expect(result).to eq(queen)
      end
    end
  end
end
