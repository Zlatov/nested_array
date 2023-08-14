# nested_array

🎉 Мои поздравления! Вышла версия 3.0.

Гем nested_array позволяет преобразовать плоский массив данных древовидной
структуры во вложенный массив, а так же помогает отобразить деревья формируя
HTML вёрстку или псевдографику.

Древовидная структура должна быть описана по шаблону Списка смежности
(Adjacency List), то есть в каждом узле указан предок.

Что мы можем получить:




## Установка

1. Добавте строку в файл _Gemfile_ вашего приложения:

```ruby
# Работа с древовидными массивами.
gem "nested_array", "~> 3.0"
```

И выполните `bundle install`.

2. Если вы планируете использовать скромные CSS стили гема, добавте в
файл _app/assets/stylesheets/application.scss_:

```css
/* Отображение древовидных массивов. */
@import "nested_array";
```




## Использование

### Работа с данными

Допустим, есть массив хэш, где хэш это узел дерева. У каждого узла есть
идентификатор `id` и указатель на родительский узел `parent_id`.

Необходим массив в котором на первом уровне будут только корневые узлы у которых
дочерние узлы помещены в поле `children`.

Пример:

```ruby
flat = [
  {'id' => 3, 'parent_id' => nil},
  {'id' => 2, 'parent_id' => 1},
  {'id' => 1, 'parent_id' => nil}
]
nested = a.to_nested
pp nested
```

Результат вывода:

```
[#<OpenStruct id=3, parent_id=nil, origin={"id"=>3, "parent_id"=>nil}, level=0>,
 #<OpenStruct id=1, parent_id=nil, children=[#<OpenStruct id=2, parent_id=1, origin={"id"=>2, "parent_id"=>1}, level=1>], origin={"id"=>1, "parent_id"=>nil}, level=0>]
```

В результате узлы представляют собой объекты OpenStruct у которых такие же поля
как у исходных объектов (id, parent_id) и дополнительные поля children, origin
и level.

В качестве исходных узлов могут быть и объекты ActiveRecord.

```ruby
a = Catalog.create!(name: 'Electronics')
b = Catalog.create!(name: 'Video Projectors', parent: a)

catalogs = Catalog.all.to_a
nested = catalogs.to_nested
pp nested
```

```
[#<OpenStruct id=1, parent_id=nil, name="Electronics", origin=#<Catalog id: 1, name: "Electronics", parent_id: nil>, children=[#<OpenStruct id=2, parent_id=1, name="Video Projectors", origin=#<Catalog id: 2, name: "Video Projectors", parent_id: 1>, level=1>], level=0>]
```

Теперь в качестве оригинала объект ActiveRecord, а узел (OpenStruct) унаследовал
поле `name` от ActiveRecord объекта, например код `nested.first.name ==
nested.first.origin.name` вернёт `true`.

<sub>Метод `.to_nested` использует метод `object.serializable_hash`, чтобы в получить список полей объекта.</sub>


### Вывод данных





## Разработка

Для подключения локальной версии гема замените в строке подключения
(файл Gemfile) второй аргумент (версию) на опцию path:

```rb
# Gemfile
# Работа с древовидными массивами
gem "nested_array", path: "../nested_array"
```
