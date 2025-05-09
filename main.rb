require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/computer'
require_relative 'lib/board'
require 'artii'

def play_game
  prompt_instructions
  loop do
    available_load_file = Dir.exist?('assets/saves') || false

    if available_load_file && yes?("\nWould you like to load a file? : ")
      file_name = choose_file
      game = load_save(file_name)
    else
      modes = %w[a b c]
      print 'Choose a mode HumanVsHuman, HumanVsComputer, ComputerVsComputer -> '
      mode = choice(modes, ', ')
      game = initialize_game(mode)
    end

    game.start

    break unless yes?("\nWould you like to play again? : ")
  end
end

def initialize_game(mode)
  board = Board.new

  case mode
  when 'a'
    white = Player.new(:white)
    black = Player.new(:black)
    Game.new(board, white, black)
  when 'b'
    white = Player.new(:white)
    Game.new(board, white)
  when 'c'
    Game.new(board)
  end
end

def load_save(file_name)
  YAML.load_file(
    "assets/saves/#{file_name}.yaml",
    permitted_classes: [Game, Board, Player, King, Queen, Pawn, Rook, Knight, Bishop, Symbol, Set, Computer],
    aliases: true
  )
end

def choose_file
  start = 'assets/saves/'.length
  last = '.yaml'.length + 1
  files = Dir['assets/saves/*'].map { |name| name.slice(start..-last) }
  print 'Choose a file to load -> '
  choice(files, ',')
end

def choice(valid_response, separator)
  loop do
    print_choices(valid_response, separator)
    choice = gets.chomp.downcase
    valid_response.each do |value|
      return value if value.slice(0..(choice.length - 1)).downcase == choice
    end
  end
end

def print_choices(choices, separator)
  choices.each do |choice|
    if choice == choices.last
      print choice.capitalize
    else
      print "#{choice.capitalize}#{separator} "
    end
  end
  print ': '
end

def yes?(prompt)
  valid_response = %w[yes no y n]
  response = ''

  loop do
    print prompt
    response = gets.chomp.downcase

    break if valid_response.include?(response)
  end

  %w[yes y].include?(response)
end

def prompt_instructions
  base = Artii::Base.new
  title = base.asciify('CL Chess')

  puts title
  puts "   Chess notations used in game:
    e5 - Pawn to e5
    dxc3 - Pawn on d takes c3
    Na3 - Knight to a3
    Nxd4 - Knight takes d4
    Nbxd4 - Knight on b takes d4
    Nbd4 - Knight on b to d4
    0-0 or O-O - King side castling
    0-0-0 or O-O-O - Queen side castling

    Legend: R - Rook | N - Knight | B - Bishop | Q - Queen | K - King

    Remember that letter case is important when entering a move\n\n"
end

play_game
