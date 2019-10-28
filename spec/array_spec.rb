require 'nested_array'

class Array
  include NestedArray::Nested
end

RSpec.describe Array, "описание Array" do

  context "С мини массивом" do
    a = [
      {id: 1, pid: nil},
      {id: 2, pid: 1},
      {id: 3, pid: nil},
    ]

    it "to_nested" do
      b = a.to_nested
      expect(b).to eq [{:id=>1, :pid=>nil, :children=>[{:id=>2, :pid=>1}]}, {:id=>3, :pid=>nil}]
    end
  end
end
