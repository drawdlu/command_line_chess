require_relative '../lib/game'

describe Game do
  subject(:game) { described_class.new }
  describe '#valid_position?' do
    context 'when A8 is entered' do
      it 'returns True' do
        result = game.valid_position?('A8')
        expect(result).to be_truthy
      end
    end

    context 'when E4 is entered' do
      it 'returns True' do
        result = game.valid_position?('E4')
        expect(result).to be_truthy
      end
    end

    context 'when I6 is entered' do
      it 'returns False' do
        result = game.valid_position?('I6')
        expect(result).to be_falsy
      end
    end

    context 'when G9 is entered' do
      it 'returns False' do
        result = game.valid_position?('G9')
        expect(result).to be_falsy
      end
    end
  end
end
