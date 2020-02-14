# NestedArray

It is intended for transformation into a tree structure of flat data described by the “Adjacency List” pattern, that is, the ancestor is specified in the nodes by the field `parent_id`. For instance:

```ruby
[
  {id: 1, parent_id: nil, name: 'first', …},
  {id: 2, parent_id:   1, name: 'second', …},
  {id: 3, parent_id:   1, name: 'third', …}
]
# ↓ ↓ ↓
[
  {id: 1, parent_id: nil, name: 'first', children: [
    {id: 2, parent_id:   1, name: 'second', …},
    {id: 3, parent_id:   1, name: 'third', …}
  ], …}
]
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nested_array', '~> 1.0.0'
```

And then execute: `bundle`.

Or install it yourself as `gem install nested_array`.

## Usage

```html
  <ul>
    <%= Catalogs.all.to_a.to_nested.nested_to_html do |node| %>
      <% link_to "#{node['name']}", catalog_view_path(node['slug']) %>
    <% end %>
  </ul>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Zlatov/nested_array.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
