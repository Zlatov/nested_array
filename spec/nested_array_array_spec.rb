require 'nested_array'

RSpec.describe NestedArray::Array, "описание NestedArray::Array" do

  context "С мини массивом" do
    a = [
      {id: 1, pid: nil},
      {id: 2, pid: 1},
      {id: 3, pid: nil},
    ]
    b = NestedArray::Array.new a
    it "to_nested" do
      c = b.to_nested
      expect(c).to eq [{:id=>1, :pid=>nil, :children=>[{:id=>2, :pid=>1}]}, {:id=>3, :pid=>nil}]
    end
  end
end
