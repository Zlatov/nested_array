require_relative '../lib/nested_array.rb'
require 'awesome_print'

a = [
  {'id' => 1, 'parent_id' => nil, 'name' => 'category 1'},
  {'id' => 2, 'parent_id' => nil, 'name' => 'category 2'},
  {'id' => 3, 'parent_id' => 2, 'name' => 'category 3'},
  {'id' => 4, 'parent_id' => nil, 'name' => 'category 4'},
  {'id' => 5, 'parent_id' => 4, 'name' => 'category 5'},
  {'id' => 6, 'parent_id' => 5, 'name' => 'category 6'},
  {'id' => 7, 'parent_id' => nil, 'name' => 'category 7'},
  {'id' => 8, 'parent_id' => 7, 'name' => 'category 8'},
  {'id' => 9, 'parent_id' => 7, 'name' => 'category 9'},
  {'id' => 10, 'parent_id' => 9, 'name' => 'category 10'},
  {'id' => 11, 'parent_id' => 9, 'name' => 'category 11'}
]

b = a.shuffle

array = b.to_nested.nested_to_options
print 'array: '.red; p array

array.each do |v|
  puts v[0]
end
