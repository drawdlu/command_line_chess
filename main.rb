require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/computer'
require_relative 'lib/board'

def play_game
  loop do
    available_load_file = Dir.exist?('assets/saves') || false

    if available_load_file && yes?("\nWould you like to load a file? : ")
      file_name = choose_file
      game = load_save(file_name)
    elsif yes?("\nWould you like to play against the Computer? : ")
      board = Board.new
      white = Player.new(:white)
      game = Game.new(board, white)
    else
      board = Board.new
      white = Player.new(:white)
      black = Player.new(:black)
      game = Game.new(board, white, black)
    end

    game.start

    break unless yes?("\nWould you like to play again? : ")
  end
end

def load_save(file_name)
  YAML.load_file(
    "assets/saves/#{file_name}.yaml",
    permitted_classes: [Game, Board, Player, King, Queen, Pawn, Rook, Knight, Bishop, Symbol, Set],
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

play_game
