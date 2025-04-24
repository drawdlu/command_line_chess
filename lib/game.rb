# frozen_string_literal: true

require_relative 'board'
require_relative 'positions'
require_relative 'player'
require_relative 'rook'
require_relative 'king'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'pawn'
require_relative 'notation'
require_relative 'computer'
require 'yaml'

# Controls game loop and special conditions
class Game
  include Positions
  include Notation

  attr_reader :board

  def initialize(board, white = Computer.new(self, :white), black = Computer.new(self, :black))
    @board = board
    @white = white
    @black = black
    @active_player = @white
    @win_draw = nil
  end

  def start
    loop do
      puts @board
      break if win_draw_condition?

      prompt_check if check?

      move = ask_for_move
      break if move.nil?

      apply_move(move[:initial_pos], move[:final_pos], @board)
      update_active_player
    end
    announce_outcome
  end

  def valid_move?(move)
    return false unless valid_code?(move)

    move_data = extract_data(move)
    return false unless taking_opponent_valid?(move_data)

    piece = piece_with_move(move_data)
    return false if piece.nil?

    !will_result_in_check?(piece, move)
  end

  private

  # PROMPTS

  def prompt_player
    puts "#{@active_player.name}'s turn to move"
  end

  def ask_for_move_position
    move = ''
    while move == ''
      print 'MOVE: '
      move = gets.chomp

      break if valid_move?(move) || valid_castling?(move) || save?(move)

      move = ''
    end

    move
  end

  def prompt_check
    print "You are in CHECK\n"
  end

  def prompt_saving
    puts "Type 'save' if you want to save current game.\n\n"
  end

  def announce_outcome
    if @win_draw == :stalemate
      puts 'Game reached STALEMATE'
    elsif @win_draw == :checkmate
      player = @active_player == @white ? @black : @white
      puts 'CHECKMATE!!'
      puts "#{player.name} HAS WON THE GAME!"
    elsif @win_draw == :draw
      puts 'Game has reached a DRAW'
    end
  end

  def prompt_multiple_pieces(pieces)
    pieces.each do |piece|
      print "#{piece.class} at #{piece.current_position} "
    end
    print "can take that position. Please clarify which one to move.\n"
  end

  def legend
    "Legend: R - Rook | N - Knight | B - Bishop | Q - Queen | K - King
          x - take opponent\n\n"
  end

  # LOOP VALIDATING INPUT

  def ask_for_move
    if @active_player.instance_of?(Computer)
      prompt_player
      move = @active_player.pick_random_move
      print "#{move}\n" unless move.instance_of?(Array) # ONLY FOR TESTING
    else
      prompt_saving
      prompt_player
      print legend
      move = ask_for_move_position
    end

    if king_side?(move) || queen_side?(move)
      castling_positions(move)
    elsif save?(move)
      save
    else
      normal_positions(move)
    end
  end

  def save?(move)
    'SAVE'.include?(move.upcase)
  end

  def castling_positions(move)
    king_pos = active_king.current_position
    initial_pos = king_pos
    letter = king_side?(move) ? 'H' : 'A'
    final_pos = "#{letter}#{king_pos[1]}"

    { final_pos: final_pos, initial_pos: initial_pos }
  end

  def normal_positions(move)
    move_data = extract_data(move)
    piece = piece_with_move(move_data)
    initial_pos = piece.current_position
    final_pos = move_data[:position]

    { final_pos: final_pos, initial_pos: initial_pos }
  end

  def valid_castling?(move)
    return false if check?

    if king_side?(move)
      valid_castling_side?('H')
    elsif queen_side?(move)
      valid_castling_side?('A')
    else
      false
    end
  end

  def valid_castling_side?(letter)
    king_pos = active_king.current_position
    rook = get_piece("#{letter}#{king_pos[1]}", @board)
    return false if rook.nil? || !rook.instance_of?(Rook)

    rook.valid_moves.include?(king_pos)
  end

  def king_side?(move)
    move == '0-0' || move.upcase == 'O-O'
  end

  def queen_side?(move)
    move == '0-0-0' || move.upcase == 'O-O-O'
  end

  def taking_opponent_valid?(move_data)
    if move_data[:take]
      !@board.empty?(move_data[:position])
    else
      @board.empty?(move_data[:position])
    end
  end

  def piece_with_move(move_data)
    pieces = active_player_pieces

    position = move_data[:position]
    piece_class = move_data[:class]
    partial_position = move_data[:piece_position]

    valid_pieces = []
    pieces.each do |piece|
      valid_pieces.push(piece) if correct_piece?(piece, partial_position, piece_class, position)
    end

    length = valid_pieces.length

    prompt_multiple_pieces(valid_pieces) if length > 1

    valid_pieces[0] if length == 1
  end

  def correct_piece?(piece, partial_position, piece_class, position)
    return false if !partial_position.nil? && !piece.current_position.include?(partial_position)

    piece.instance_of?(piece_class) &&
      piece.valid_moves.include?(position)
  end

  # UPDATING DATA

  def apply_move(initial_pos, final_pos, board_to_apply)
    piece = get_piece(initial_pos, board_to_apply)
    second_piece = get_piece(final_pos, board_to_apply)

    if castling?(piece, second_piece)
      board_to_apply.handle_castling_move(initial_pos, final_pos)
    else
      board_to_apply.move_to(initial_pos, final_pos)
      piece.update_position(final_pos)
      board_to_apply.update_last_move(initial_pos, final_pos, piece)
    end

    promote_if_pawn(piece) if @board == board_to_apply
    board_to_apply.update_valid_moves
  end

  def promote_if_pawn(piece)
    return unless piece.instance_of?(Pawn) && piece.last_row?

    if @active_player.instance_of?(Computer)
      piece.promote('QUEEN')
    else
      piece.promote
    end
  end

  # the only move where you can pick an ally to move to is Castling
  def castling?(piece1, piece2)
    return false if piece2.nil?

    piece1.color == piece2.color
  end

  def update_active_player
    @active_player = @active_player == @white ? @black : @white
  end

  # CHECK, CHECKMATE, STALEMATE, DRAW

  def check?
    @board.check?(@active_player.color)
  end

  def will_result_in_check?(piece, move)
    board_copy = Marshal.load(Marshal.dump(@board))
    apply_move(piece.current_position, move[-2..].upcase, board_copy)

    board_copy.check?(@active_player.color)
  end

  def two_kings_left
    @board.white_pieces.length == 1 && @board.black_pieces.length == 1
  end

  def stalemate?
    opponent_controls_king_moves? && no_more_moves? && !check?
  end

  def no_more_moves?
    get_pieces(@active_player.color).each do |piece|
      return false if !piece.instance_of?(King) && !piece.valid_moves.empty?
    end

    true
  end

  def opponent_controls_king_moves?
    king = active_king
    return false if king.valid_moves.empty?

    found = Set[]
    king.valid_moves.each do |move|
      found.add(move) if will_result_in_check?(king, move)
    end

    found == king.valid_moves
  end

  def checkmate?
    opponent_controls_king_moves? && check? && no_move_to_protect?
  end

  def no_move_to_protect?
    pieces = active_player_pieces
    pieces.each do |piece|
      next if piece.instance_of?(King)

      return false if ally_contains_protect_king(piece)
    end
    true
  end

  def ally_contains_protect_king(piece)
    piece.valid_moves.each do |move|
      return true unless will_result_in_check?(piece, move)
    end

    false
  end

  def win_draw_condition?
    if checkmate?
      @win_draw = :checkmate
      return true
    elsif stalemate?
      @win_draw = :stalemate
      return true
    elsif two_kings_left
      @win_draw = :draw
      return true
    end

    false
  end

  # HELPERS EXTRACTING DATA

  def active_king
    if @active_player.color == :white
      get_from_set(@board.white_pieces, King)
    else
      get_from_set(@board.black_pieces, King)
    end
  end

  def active_player_pieces
    if @active_player.color == :white
      @board.white_pieces
    else
      @board.black_pieces
    end
  end

  def get_from_set(set_pieces, piece_class)
    set_pieces.each do |piece|
      return piece if piece.instance_of?(piece_class)
    end

    nil
  end

  def get_pieces(color)
    if color == :black
      @board.black_pieces
    else
      @board.white_pieces
    end
  end

  # SAVING

  def save
    file_name = choose_name
    create_save_directory
    save_to_file(file_name)
    puts 'Successfully saved the game'
  end

  def choose_name
    puts
    print 'Type a file name for your save file: '
    gets.chomp
  end

  def create_save_directory
    Dir.mkdir 'assets/saves' unless Dir.exist? 'assets/saves'
  end

  def save_to_file(file_name)
    serialized = YAML.dump self
    file = if File.exist?("assets/saves/#{file_name}.yaml")
             File.open("assets/saves/#{file_name}.yaml", 'w')

           else
             File.new("assets/saves/#{file_name}.yaml", 'w')
           end
    file.write(serialized)
    file.close
  end
end
