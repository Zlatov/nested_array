require 'nested_array'





RSpec.describe NestedArray::Array, "описание" do

  context "С малым массивом" do
    a = load_json_fixture "small_flat"
    a = NestedArray::Array.new a

    it "to_nested" do
      b = a.to_nested id: "id", parent_id: "parent_id", children: "children"
      expect(b).to eq load_json_fixture("small_nested")
    end
  end
end
