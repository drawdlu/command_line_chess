require_relative '../lib/positions'

describe Positions do
  let(:position_mod) { Class.new { extend Positions } }
  describe '#get_name_index' do
    context 'when "A1" is passed in' do
      it 'will return [7, 0]' do
        result = position_mod.get_name_index('A1')
        expect(result).to eq([7, 0])
      end
    end

    context 'when "D5" is passed in' do
      it 'will return [3, 3]' do
        result = position_mod.get_name_index('D5')
        expect(result).to eq([3, 3])
      end
    end
  end
end
