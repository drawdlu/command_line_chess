# frozen_string_literal: true

# converting position names and index
module Positions
  LETTER_POSITIONS = %w[A B C D E F G H].freeze

  def get_name_index(position)
    letter = position[0]
    number = position[1]

    x_index = letter.ord - 'A'.ord
    y_index = 8 - number.to_i
    [y_index, x_index]
  end

  def square_name(x_index, y_index)
    LETTER_POSITIONS[x_index] + (8 - y_index).to_s
  end
end
