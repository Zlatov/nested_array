RSpec.describe NestedArray do
  # it 'Инстанс класса Array обладает методом to_nested после подключения гема' do
  #   expect(Array.instance_methods.include?(:to_nested)).to eq(true)
  # end

  it 'Инстанс класса Array обладает всеми запланированными методами' do
    # blank_array = [:to_nested, :to_flat, :each_nested] - Array.instance_methods
    # expect(blank_array.length).to eq(0)
    expect(Array.instance_methods.include?(:to_nested)).to eq(true)
    expect(Array.instance_methods.include?(:to_flat)).to eq(true)
    expect(Array.instance_methods.include?(:each_nested)).to eq(true)
  end
end
