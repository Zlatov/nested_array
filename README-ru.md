# NestedArray

Предназначен для преобразования в древовидную структуру плоских данных описанных по паттерну «Список смежности» (Adjacency List), то есть в нодах указа предок `parent_id`. Например:

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


## Установка

Добавте строку в _Gemfile_ вашего приложения:

```ruby
gem 'nested_array', '~> 2.0.0'
```

И затем выполните `bundle`.

Или установите его как `gem install nested_array`


## Использование

```html
  <ul>
    <%= Catalogs.all.to_a.to_nested.nested_to_html do |node| %>
      <% link_to "#{node['name']}", catalog_view_path(node['slug']) %>
    <% end %>
  </ul>
```

__Опции `to_nested`__

`Catalogs.all.to_a.to_nested(options)`

Для указания базовых имён полей ноды (чувствительны к string/symbol):

```
id: 'id',
parent_id: 'parent_id',
children: 'children',
level: 'level',
```

Дополнительные параметры преобразования:

```
hashed: false,
add_level: false,
root_id: nil,
```

__Опции `nested_to_html`__

```
tabulated: true,
inline: false,
tab: "\t",
ul:  '<ul>',
_ul: '</ul>',
li:  '<li>',
_li: '</li>',
```

### "Скеивание" вложенных структур `concat_nested`

Ноды склеиваются если путь к ним одинаков;
Путь определяется из сложения Текстов (конфигурируемо через :path_key);

__Опции `nested_to_html`__

```
path_separator: '-=path_separator=-',
path_key: 'text',
```

### Формирования опций для html-тега &lt;select&gt; `nested_to_options`

Возвращает массив с псевдографикой, позволяющей вывести древовидную структуру.

```
[['option_text1', 'option_value1'],['option_text2', 'option_value2'],…]
```

__Опции `nested_to_options`__

```
option_value: 'id', # Что брать в качестве значений при формировании опций селекта.
option_text: 'name',
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Zlatov/nested_array.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
