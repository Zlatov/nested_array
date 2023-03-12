RSpec.describe NestedArray::Nested do

  context 'to_nested' do
    flat = [
      { 'id' => 3, 'parent_id' => nil },
      { 'id' => 2, 'parent_id' => 1 },
      { 'id' => 1, 'parent_id' => nil }
    ]

    it 'to_nested ожидаемо отрабатывает на массиве' do
      nested = flat.to_nested
      origin_3 = nested[0].origin
      origin_2 = nested[1].children[0].origin
      origin_1 = nested[1].origin
      expect(origin_3).to eq flat[0]
      expect(origin_2).to eq flat[1]
      expect(origin_1).to eq flat[2]
    end
  end
end
