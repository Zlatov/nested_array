require "active_support/all"
require "nested_array/version"

require_relative "nested_array/nested"

module NestedArray

  class Array < ::Array

    include NestedArray::Nested
  end
end
