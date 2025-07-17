# rspec ./spec/lib/nested_array/nested_spec.rb
RSpec.describe NestedArray::Nested do
  let(:flat) do
    [
      { 'id' => 3, 'parent_id' => nil },
      { 'id' => 2, 'parent_id' => 1 },
      { 'id' => 1, 'parent_id' => nil }
    ]
  end

  let(:empty_flat){[]}

  let(:easy_flat) do
    [
      { 'id' => 2, 'parent_id' => 1 },
      { 'id' => 1, 'parent_id' => nil }
    ]
  end

  describe '#to_nested' do
    it 'возвращает массив' do
      expect(flat.to_nested).to be_a(Array)
      expect(empty_flat.to_nested).to be_a(Array)
    end

    it 'вкладывает ребёнка в родителя' do
      result = easy_flat.to_nested

      expect(result.size).to eq(1)
      expect(result[0].id).to eq(1)
      expect(result[0].children[0].id).to eq(2)
    end

    it 'сохраняет ссылки на оригинальные объекты в node.origin' do
      result = flat.to_nested

      expect(result[0].origin.object_id).to eq(flat[0].object_id)
      expect(result[1].origin.object_id).to eq(flat[2].object_id)
      expect(result[1].children[0].origin.object_id).to eq(flat[1].object_id)
    end

    it 'не уходит в бесконечный цикл при циклических связях' do
      cyclic = [
        { 'id' => 1, 'parent_id' => 2 },
        { 'id' => 2, 'parent_id' => 1 }
      ]

      expect { cyclic.to_nested }.not_to raise_error
      expect(cyclic.to_nested).to be_an(Array)
    end

    it 'работает с ActiveRecord-подобными объектами' do
      record1 = DummyRecord.new(1, nil)
      record2 = DummyRecord.new(2, 1)
      record3 = DummyRecord.new(3, 1)

      input = [record1, record2, record3]

      nested = input.to_nested

      expect(nested.size).to eq(1)
      expect(nested.first.id).to eq(1)
      expect(nested.first.children.map(&:id)).to match_array([2, 3])
    end
  end
end
