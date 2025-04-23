require_relative 'positions'

# Converts and verifies notations
module Notation
  include Positions

  MOVES = { N: Knight, B: Bishop, R: Rook, Q: Queen, K: King }.freeze

  def valid_code?(move)
    return false unless valid_position?(move[-2..])

    length = move.length

    case length
    when 2
      two = /[a-h]\d/
      two.match?(move)
    when 3
      three = /[N|Q|K|B|R][a-h]\d/
      three.match?(move)
    when 4
      four = /[a-h|N|Q|K|B|R][x|\d|a-h][a-h]\d/
      four.match?(move) && valid_length_four?(move)
    when 5
      five = /[N|Q|K|B|R][\d|a-h]x[a-h]\d/
      five.match?(move) && valid_length_five?(move)
    else
      false
    end
  end

  def valid_length_four?(move)
    if MOVES.key?(move[0].to_sym)
      move[1] != move[3] && move[1] != move[2]
    else
      move[1] == 'x'
    end
  end

  def valid_length_five?(move)
    move[1] != move[3] && move[1] != move[4]
  end

  def extract_data(move)
    data = { class: Pawn, piece_position: nil, take: false, position: nil }

    data[:position] = move[-2..].upcase

    other_data = move[0..-3]
    extract_additional_data(other_data, data)
  end

  def extract_additional_data(other_data, data)
    other_data.chars.each do |char|
      if MOVES.key?(char.to_sym)
        data[:class] = MOVES[char.to_sym]
      elsif char.match?(/\d/) || char.match?(/[a-h]/)
        data[:piece_position] = char.upcase
      elsif char == 'x'
        data[:take] = true
      end
    end

    data
  end
end
