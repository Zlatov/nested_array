#!/usr/bin/env bash

set -eu

cd "$(dirname "${0}")"

cd ../..

# rspec управляет загружаемыми гемами, поэтому сам rspec запускается НЕ `bundle exec rspec`, а просто `rspec`
./bin/rspec --format doc ./spec/array_spec.rb
./bin/rspec --format doc ./spec/nested_array_array_spec.rb
