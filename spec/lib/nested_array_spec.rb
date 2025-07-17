# rspec ./spec/lib/nested_array_spec.rb
RSpec.describe NestedArray do
  it 'Инстанс класса Array обладает всеми запланированными методами' do
    expect(Array.instance_methods.include?(:to_nested)).to eq(true)
    expect(Array.instance_methods.include?(:to_flat)).to eq(true)
    expect(Array.instance_methods.include?(:each_nested)).to eq(true)
  end
end
