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

  def initialize(board, white, black = Computer.new(self))
    prompt_instructions
    @board = board
    @white = white
    @black = black
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
      break if move.nil?

      apply_move(move[:initial_pos], move[:final_pos])
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

    valid_start?(piece, piece.current_position) && valid_move_position?(piece, move_data[:position])
  end

  private

  def announce_outcome
    if @win_draw.nil?
      puts 'Game reached STALEMATE'
    else
      player = @active_player == @white ? @black : @white
      puts 'CHECKMATE!!'
      puts "#{player.name} HAS WON THE GAME!"
    end
  end

  def prompt_instructions
    puts "Chess notations used in game:
    e5 - Pawn to e5
    dxc3 - Pawn on d takes c3
    Na3 - Knight to a3
    Nxd4 - Knight takes d4
    Nbxd4 - Knight on b takes d4 (this is only essential when 2 of your Knights can take that spot)
    Nbd4 - Knight on b to d4 (again, this is only needed when 2 of your Knights can go to that spot)
    0-0 or O-O - King side castling
    0-0-0 or O-O-O - Queen side castling

    Legend: R - Rook | N - Knight | B - Bishop | Q - Queen | K - King

    Remember that letter case is important when entering a move\n\n"
  end

  def legend
    "Legend: R - Rook | N - Knight | B - Bishop | Q - Queen | K - King
          x - take opponent\n\n"
  end

  def prompt_check
    print "You are in CHECK\n"
  end

  def update_active_player
    @active_player = @active_player == @white ? @black : @white
  end

  def ask_for_move
    if @active_player.instance_of?(Computer)
      prompt_player
      move = @active_player.pick_random_move
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

  def prompt_saving
    puts "Type 'save' if you want to save current game.\n\n"
  end

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

  def save?(move)
    'SAVE'.include?(move.upcase)
  end

  def valid_castling?(move)
    return false unless @opponent_pieces_in_check.empty?

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

  def prompt_multiple_pieces(pieces)
    pieces.each do |piece|
      print "#{piece.class} at #{piece.current_position} "
    end
    print "can take that position. Please clarify which one to move.\n"
  end

  def correct_piece?(piece, partial_position, piece_class, position)
    return false if !partial_position.nil? && !piece.current_position.include?(partial_position)

    piece.instance_of?(piece_class) &&
      piece.valid_moves.include?(position) &&
      valid_start?(piece, piece.current_position)
  end

  def valid_start?(piece, position)
    check_num = @opponent_pieces_in_check.length
    if check_num.positive?
      return ally_king.current_position == position if check_num > 1

      initial_could_remove_check?(position)
    elsif piece.instance_of?(King)
      !opponent_controls_king_moves?
    else
      does_not_result_in_check?(piece)
    end
  end

  def does_not_result_in_check?(piece)
    opponent_pieces = if @active_player.color == :white
                        get_pieces(:black)
                      else
                        get_pieces(:white)
                      end

    !opens_path_to_king?(piece, opponent_pieces)
  end

  # if piece is moved
  def opens_path_to_king?(piece, opponent_pieces)
    position = piece.current_position

    return false unless piece.diagonal?(position) || piece.vertical_horizontal?(position)

    king_position = active_king.current_position
    direction_to_king = [get_direction(position[1], king_position[1]),
                         get_direction(position[0], king_position[0])]

    position = piece.current_position

    opponent_pieces.each do |opponent|
      next unless opponent.valid_moves.include?(position)

      opponent_position = opponent.current_position
      direction_to_position = [get_direction(opponent_position[1], position[1]),
                               get_direction(opponent_position[0], position[0])]

      return true if direction_to_king == direction_to_position
    end

    false
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
    protect_moves = squares_to_protect_king
    piece.valid_moves.each do |move|
      return true if protect_moves.include?(move)
    end

    false
  end

  def squares_to_protect_king
    king_position = active_king.current_position
    opponent_position = @opponent_pieces_in_check[0].current_position
    x_direction = get_direction(king_position[1], opponent_position[1])
    y_direction = get_direction(king_position[0], opponent_position[0])
    active_king.directional_moves([{ x: x_direction, y: y_direction }]) + Set[opponent_position]
  end

  def valid_move_position?(piece, move)
    check_num = @opponent_pieces_in_check.length
    valid = if check_num.positive?
              if piece.instance_of?(King)
                not_opponent_controlled(move)
              else
                move_to_protect?(move)
              end
            elsif piece.instance_of?(King)
              not_opponent_controlled(move)
            else
              true
            end

    @opponent_pieces_in_check = [] if valid

    valid
  end

  def move_to_protect?(move)
    squares_to_protect_king.include?(move) ||
      @opponent_pieces_in_check[0].current_position == move
  end

  def not_opponent_controlled(move)
    opponent_pieces = @active_player.color == :white ? @board.black_pieces : @board.white_pieces

    opponent_pieces.each do |piece|
      return false if piece.valid_moves.include?(move) || piece_can_take_position(piece, move)
    end

    true
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
    ally_king = active_king.current_position
    opponent_color = @active_player.color == :white ? :black : :white

    get_pieces(opponent_color).each do |piece|
      check.push(piece) if piece.valid_moves.include?(ally_king)
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

  def win_draw_condition?
    if stalemate?
      @win_draw = :draw
      return true
    elsif checkmate?
      @win_draw = :checkmate
      return true
    end

    false
  end

  def checkmate?
    opponent_controls_king_moves? && check? && no_move_to_protect?
  end

  def no_move_to_protect?
    return true if @opponent_pieces_in_check.length > 1

    pieces = active_player_pieces
    pieces.each do |piece|
      next if piece.instance_of?(King)

      return false if ally_contains_protect_king(piece)
    end
    true
  end

  def stalemate?
    opponent_controls_king_moves? && no_more_moves?
  end

  def no_more_moves?
    get_pieces(@active_player.color).each do |piece|
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
        if piece.valid_moves.include?(move) && @board.empty?(move)
          found.add(move)
          break
        elsif !@board.empty?(move)
          if piece_can_take_position(piece, move)
            found.add(move)
            break
          end
        end
      end
    end

    found == king.valid_moves
  end

  def piece_can_take_position(piece, position)
    perimeter = positions_around(position)
    if piece.instance_of?(Knight)
      piece.all_moves(Knight::KNIGHT_MOVES).include?(position)
    elsif piece.instance_of?(King)
      piece.all_moves(King::KING_MOVES).include?(position)
    elsif piece.instance_of?(Bishop)
      piece.diagonal?(position) && piece.valid_moves.intersect?(perimeter) ||
        piece.diagonal?(position) && perimeter.include?(piece.current_position)
    elsif piece.instance_of?(Rook)
      piece.vertical_horizontal?(position) && piece.valid_moves.intersect?(perimeter) ||
        piece.vertical_horizontal?(position) && perimeter.include?(piece.current_position)
    elsif piece.instance_of?(Pawn)
      below_num = (position[1].to_i - 1).to_s
      piece.diagonal?(position) &&
        perimeter.include?(piece.current_position) &&
        piece.current_position[1] == below_num
    elsif piece.instance_of?(Queen)
      if piece.diagonal?(position) || piece.vertical_horizontal?(position)
        piece.valid_moves.intersect?(perimeter) || perimeter.include?(piece.current_position)
      else
        false
      end
    end
  end

  def opponent_color
    @active_player.color == :white ? :black : :white
  end
end
