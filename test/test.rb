require 'active_support/all'
require 'awesome_print'
require 'nested_array'

puts 'Начато тестирование.'.blue
puts "Версия руби: #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"

def to_nested_1
  puts "Тестирование #{__method__}".blue
  a = [
    {'id' => 1, 'parent_id' => nil, 'name' => 'first'},
    {'id' => 2, 'parent_id' => 1, 'name' => 'second'},
    {'id' => 3, 'parent_id' => 1, 'name' => 'third'}
  ]
  a = NestedArray::Array.new a
  b = a.to_nested
  return false if b != [
    {'id' => 1, 'parent_id' => nil, 'name' => 'first', 'children' => [
      {'id' => 2, 'parent_id' => 1, 'name' => 'second'},
      {'id' => 3, 'parent_id' => 1, 'name' => 'third'}
    ]},
  ]
  b = a.to_nested add_level: true
  return false if b != [
    {'id' => 1, 'parent_id' => nil, 'name' => 'first', 'level' => 0, 'children' => [
      {'id' => 2, 'parent_id' => 1, 'name' => 'second', 'level' => 1},
      {'id' => 3, 'parent_id' => 1, 'name' => 'third', 'level' => 1}
    ]},
  ]
  return true
end




begin
  raise if !to_nested_1
rescue => e
  puts 'Тестирование не пройдено.'.red
  exit 1
end
puts 'Тестирование пройдено.'.green
