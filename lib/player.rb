# frozen_string_literal: true

# Handles player name and color
class Player
  attr_reader :color, :name

  def initialize(color)
    @name = get_name(color)
    @color = color
  end

  private

  def get_name(color)
    name = ''

    while name == ''
      print "\nEnter player name for #{color.upcase} pieces: "
      name = gets.chomp
    end

    name
  end
end
