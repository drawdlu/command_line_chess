require_relative '../lib/positions'

describe Positions do
  let(:position_mod) { Class.new { extend Positions } }
  describe '#get_name_index' do
    context 'when "A1" is passed in' do
      it 'will return { x: 7, y: 0 }' do
        result = position_mod.get_name_index('A1')
        expect(result).to eq({ x: 7, y: 0 })
      end
    end

    context 'when "D5" is passed in' do
      it 'will return { x: 3, y: 3 }' do
        result = position_mod.get_name_index('D5')
        expect(result).to eq({ x: 3, y: 3 })
      end
    end
  end

  describe '#positions_around' do
    context 'when E4' do
      it 'will return Set[D5 E5 F5 F4 D4 D3 E3 F3]' do
        result = position_mod.positions_around('E4')
        positions_set = Set['D5', 'E5', 'F5', 'F4', 'D4', 'D3', 'E3', 'F3']
        expect(result).to eq(positions_set)
      end
    end

    context 'when E4' do
      it 'will return Set[A2, B2, B1]' do
        result = position_mod.positions_around('A1')
        positions_set = Set['A2', 'B2', 'B1']
        expect(result).to eq(positions_set)
      end
    end
  end
end
