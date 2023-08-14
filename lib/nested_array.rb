require "active_support/all"

require_relative "nested_array/version"
require_relative "nested_array/nested"

module NestedArray
  class Array < ::Array
    include NestedArray::Nested
  end

  class Engine < ::Rails::Engine
  end
end

class Array
  include ::NestedArray::Nested
end
