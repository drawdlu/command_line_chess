# frozen_string_literal: true

# Handles player name and color
class Player
  def initialize(color)
    @name = get_name(color)
    @color = color
  end

  private

  def get_name(color)
    name = ''

    while name == ''
      print "Enter player name for #{color.upcase} pieces: "
      name = gets.chomp
    end

    name
  end
end
