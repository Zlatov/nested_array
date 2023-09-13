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

  context 'Метод to_nested' do
    it 'Возвращает массив' do
      nested = flat.to_nested
      empty_nested = empty_flat.to_nested

      expect(nested).to be_instance_of(Array)
      expect(empty_nested).to be_instance_of(Array)
    end

    it 'Вкладывает ребёнка в родителя' do
      nested = easy_flat.to_nested

      expect(nested.length).to eq(1)
      expect(nested[0].id).to eq(1)
      expect(nested[0].children[0].id).to eq(2)
    end

    it 'Сохраняет оригиналы' do
      nested = flat.to_nested

      expect(nested[0].origin.object_id).to eq(flat[0].object_id)
      expect(nested[1].origin.object_id).to eq(flat[2].object_id)
      expect(nested[1].children[0].origin.object_id).to eq(flat[1].object_id)
    end
  end
end
