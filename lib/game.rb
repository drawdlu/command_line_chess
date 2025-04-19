# frozen_string_literal: true

require_relative 'board'
require_relative 'positions'
require_relative 'player'
require_relative 'rook'
require_relative 'king'

# Controls game loop and special conditions
class Game
  include Positions

  def initialize
    @board = Board.new
    @white = Player.new(:white)
    @black = Player.new(:black)
    @active_player = @white
    @win_draw = nil
    @opponent_pieces_in_check = []
  end

  def start
    loop do
      @board.update_valid_moves
      puts @board
      break if win_draw_condition?

      prompt_check if check?

      move = ask_for_move
      apply_move(move[:initial_pos], move[:final_pos])
      update_active_player
    end
    announce_outcome
  end

  private

  def prompt_check
    print "You are in CHECK\n"
  end

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
    second_piece = get_piece(final_pos, @board)

    if castling?(piece, second_piece)
      @board.handle_castling_move(initial_pos, final_pos)
    else
      @board.move_to(initial_pos, final_pos)
      piece.update_position(final_pos)
      @board.update_last_move(initial_pos, final_pos, piece)
    end
  end

  # the only move where you can pick an ally to move to is Castling
  def castling?(piece1, piece2)
    return false if piece2.nil?

    piece1.color == piece2.color
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

    valid = valid_position?(position) &&
            !@board.empty?(position) &&
            ally?(position) &&
            !piece.valid_moves.empty?

    check_num = @opponent_pieces_in_check.length
    if check_num.positive? && valid
      return ally_king.current_position == position if check_num > 1

      valid = initial_could_remove_check?(position)
    end

    valid
  end

  def initial_could_remove_check?(position)
    piece = get_piece(position, @board)

    if active_king == piece
      !opponent_controls_king_moves?
    else
      ally_contains_protect_king(piece)
    end
  end

  def ally_contains_protect_king(piece)
    opponent_position = @opponent_pieces_in_check[0].current_position
    piece.valid_moves.include?(square_to_protect_king) ||
      piece.valid_moves.include?(opponent_position)
  end

  def square_to_protect_king
    king_position = active_king.current_position
    opponent_position = @opponent_pieces_in_check[0].current_position
    x_direction = get_direction(king_position[1], opponent_position[1])
    y_direction = get_direction(king_position[0], opponent_position[0])
    move_pos(king_position, x_direction, y_direction)
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

  def check?
    update_opponent_pieces_in_check
    @opponent_pieces_in_check.length.positive?
  end

  def update_opponent_pieces_in_check
    check = []
    ally_king = active_king
    opponent_color = @active_player.color == :white ? :black : :white

    get_pieces(opponent_color).each do |piece|
      check.push(piece) if piece.valid_moves.include?(ally_king.current_position)
    end

    @opponent_pieces_in_check = check
  end

  def get_from_set(set_pieces, piece_class)
    set_pieces.each do |piece|
      return piece if piece.instance_of?(piece_class)
    end

    nil
  end

  def active_king
    if @active_player.color == :white
      get_from_set(@board.white_pieces, King)
    else
      get_from_set(@board.black_pieces, King)
    end
  end

  def get_pieces(color)
    if color == :black
      @board.black_pieces
    else
      @board.white_pieces
    end
  end

  def announce_outcome
    return unless @win_draw.nil?

    puts 'Game reached STALEMATE'
  end

  def win_draw_condition?
    stalemate?
  end

  def stalemate?
    opponent_controls_king_moves? && no_more_moves?
  end

  def no_more_moves?
    get_pieces(@active_player.color).each do |piece|
      print "#{piece.class} #{piece.valid_moves} #{piece.current_position}"
      return false if !piece.instance_of?(King) && !piece.valid_moves.empty?
    end

    true
  end

  def active_player_pieces
    if @active_player.color == :white
      @board.white_pieces
    else
      @board.black_pieces
    end
  end

  def opponent_controls_king_moves?
    king = active_king
    return false if king.valid_moves.empty?

    found = Set[]

    king.valid_moves.each do |move|
      get_pieces(opponent_color).each do |piece|
        if piece.valid_moves.include?(move)
          found.add(move)
          break
        end
      end
    end

    found == king.valid_moves
  end

  def opponent_color
    @active_player.color == :white ? :black : :white
  end
end
