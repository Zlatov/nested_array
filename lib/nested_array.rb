require "active_support/all"

require_relative "nested_array/version"
require_relative "nested_array/nested"
require_relative "nested_array/engine" # Подключаем engine отдельно

module NestedArray
  class Array < ::Array
    include NestedArray::Nested
  end
end

# Monkey-patch стандартного Array
class Array
  include ::NestedArray::Nested
end
