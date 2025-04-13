# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/positions'
require_relative '../lib/player'

# Controls game loop and special conditions
class Game
  include Positions

  def initialize
    @board = Board.new
    @white = Player.new(:white)
    @black = Player.new(:black)
    @active_player = @white
  end

  def start
    loop do
      update_valid_moves
      puts @board
      move = ask_for_move
      apply_move(move[:initial_pos], move[:final_pos])
      update_active_player
    end
  end

  private

  def update_active_player
    @active_player = @active_player == @white ? @black : @white
  end

  def ask_for_move
    prompt_player
    initial_pos = ask_start_position
    piece = get_piece(initial_pos, @board)
    final_pos = get_move_position(piece)

    { final_pos: final_pos, initial_pos: initial_pos }
  end

  def apply_move(initial_pos, final_pos)
    piece = get_piece(initial_pos, @board)
    @board.move_to(initial_pos, final_pos)
    piece.update_position(final_pos)
    @board.update_last_move(initial_pos, final_pos, piece)
  end

  def prompt_player
    puts "#{@active_player.name}'s turn to move"
  end

  def ask_start_position
    move = ''
    while move == ''
      print 'PIECE: '
      move = gets.chomp.upcase

      break if valid_start?(move)

      move = ''
    end

    move.upcase
  end

  def valid_start?(position)
    piece = get_piece(position, @board)

    valid_position?(position) &&
      !@board.empty?(position) &&
      ally?(position) &&
      !piece.valid_moves.empty?
  end

  def get_move_position(piece)
    move = ''
    while move == ''
      print 'SQUARE to move to: '
      move = gets.chomp.upcase

      break if valid_position?(move) && piece.valid_moves.include?(move)

      move = ''
    end

    move.upcase
  end

  def ally?(position)
    index = get_name_index(position)

    @board.board[index[:x]][index[:y]].color == @active_player.color
  end

  def update_valid_moves
    update_moves_set(@board.black_pieces)
    update_moves_set(@board.white_pieces)
  end

  def update_moves_set(set_pieces)
    set_pieces.each do |piece|
      if @board.last_move.nil?
        piece.change_valid_moves
      elsif includes_last_move(piece) || piece.instance_of?(Pawn)
        piece.change_valid_moves
      end
    end
  end

  def includes_last_move(piece)
    piece.valid_moves.include?(@board.last_move[:from]) ||
      piece.valid_moves.include?(@board.last_move[:to])
  end
end
