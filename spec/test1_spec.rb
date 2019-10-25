require 'nested_array'

RSpec.describe NestedArray, "#score" do
  context "with no strikes or spares" do
    it "sums the pin count for each roll" do
      a = [
        {id: 1, pid: nil},
        {id: 2, pid: 1},
        {id: 3, pid: nil},
      ]
      b = a.to_nested
      expect(b).to eq [{:id=>1, :pid=>nil, :children=>[{:id=>2, :pid=>1}]}, {:id=>3, :pid=>nil}]
    end
  end
end
