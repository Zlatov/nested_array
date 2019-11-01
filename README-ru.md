# NestedArray

Предназначен для преобразования в древовидную структуру плоских данных описанных по паттерну «Список смежности» (Adjacency List), то есть в нодах указа предок `parent_id`.

```ruby
[
  {id: 1, parent_id: nil, name: 'first', …},
  {id: 2, parent_id:   1, name: 'second', …},
  …
]
# ↓ ↓ ↓
[
]
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nested_array'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nested_array

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nested_array.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
