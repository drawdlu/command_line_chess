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
      puts @board
      prompt_player
      initial_pos = get_start_position
      piece = get_piece(initial_pos)
      final_pos = get_move_position(piece)
      @board.move_to(initial_pos, final_pos)
      piece.update_position(final_pos)
      @active_player = @active_player == @white ? @black : @white
    end
  end

  private

  def prompt_player
    puts "#{@active_player.name}'s turn to move"
  end

  def get_piece(position)
    return nil if @board.empty?(position)

    index = get_name_index(position)
    @board.board[index[:x]][index[:y]]
  end

  def get_start_position
    move = ''
    while move == ''
      print 'PIECE: '
      move = gets.chomp.upcase

      return move.upcase if valid_position?(move) &&
                            !@board.empty?(move) &&
                            ally?(move)

      move = ''
    end
  end

  def get_move_position(piece)
    move = ''
    while move == ''
      print 'SQUARE to move to: '
      move = gets.chomp.upcase

      return move if valid_position?(move) && piece.valid_move?(move)

      move = ''
    end
  end

  def valid_position?(position)
    valid_positions = /[A-Ha-h][1-8]/
    vool = valid_positions.match?(position) # rubocop:disable Style/RedundantAssignment

    vool
  end

  def ally?(position)
    index = get_name_index(position)

    @board.board[index[:x]][index[:y]].color == @active_player.color
  end

  def remove_piece(piece)
    return if piece.nil?

    if piece.color == :white
      @board.white_pieces.delete(piece)
    else
      @board.black_pieces.delete(piece)
    end
  end
end
