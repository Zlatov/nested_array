# nested_array

🎉 Congratulations! Version 3.0 has been released.

Gem `nested_array` allows you to convert a flat data array with a tree structure
into a nested array. It also helps to display trees by forming HTML layout or
pseudo-graphics.

The tree structure must be described using the Adjacency List pattern, that is, each node has an ancestor.

__Select language README.md__

-   en [English](README.md)
-   ru [Русский](README-ru.md)




## <a id="Оглавление"></a>Table of contents
-   [Installation](#1)
-   [Usage](#2)
    -   [Converting data using the `.to_nested` method](#2.1)
        -   [Source data – hash array](#2.1.1)
        -   [Source data – ActiveRecord array](#2.1.2)
        -   [`.to_nested` method options](#2.1.3)
            -   [`root_id: id`](#2.1.3.1)
            -   [`branch_id: id`](#2.1.3.2)
    -   [Displaying tree structures](#2.2)
        -   [As multi-level lists](#2.2.1)
            -   [Bulleted and numbered lists `<ul>`, `<ol>`](#2.2.1.1)
            -   [Using your own templates to display a list](#2.2.1.2)
            -   [Changing the template depending on node data](#2.2.1.3)
            -   [Dropdown list based on `<details></details>` tag](#2.2.1.4)
            -   [Formation and output of your own templates based on changing the node level `node.level`](#2.2.1.5)
        -   [Pseudo-graphic output](#2.2.2)
            -   [Adding pseudo-graphics before the model name using the `nested_to_options` method](#2.2.2.1)
            -   [Thin pseudographics](#2.2.2.2)
            -   [Own pseudographics](#2.2.2.3)
            -   [Increase indentation in own pseudographics](#2.2.2.4)
        -   [In html forms](#2.2.3)
            -   [With the `form.select` helper](#2.2.3.1)
            -   [With `form.select` and `options_for_select` helpers](#2.2.3.2)
            -   [Dropdown list with radio buttons `form.radio_button`](#2.2.3.3)




## <a id="1"></a>Installation [↑](#Оглавление "To the table of contents")

1. Add a line to your application's Gemfile:

```ruby
# Working with tree arrays
gem "nested_array", "~> 3.0"
```

And do `bundle install`.

2.  If you plan to use modest CSS gem styles, add to
    the _app/assets/stylesheets/application.scss_ file:

```css
/* Displaying Tree Arrays */
@import "nested_array";
```




## <a id="2"></a>Usage [↑](#Оглавление "To the table of contents")

### <a id="2.1"></a>Converting data using the `.to_nested` method [↑](#Оглавление "To the table of contents")

#### <a id="2.1.1"></a>Source data – hash array [↑](#Оглавление "To the table of contents")

Let's say we have a hash array:

```rb
flat = [
  {'id' => 3, 'parent_id' => nil},
  {'id' => 2, 'parent_id' => 1},
  {'id' => 1, 'parent_id' => nil}
]
```

Where each hash is a tree node, `id` is the node identifier, `parent_id` is a
pointer to the parent node.

It is necessary to convert it into an array in which there will be root nodes
(`'parent_id' => nil`), and child nodes placed in the `children` field.

```rb
nested = flat.to_nested
puts nested.pretty_inspect
```

This will output:

```
[#<OpenStruct id=3, parent_id=nil, level=0, origin={"id"=>3, "parent_id"=>nil}>,
 #<OpenStruct id=1, parent_id=nil, level=0, children=[#<OpenStruct id=2, parent_id=1, level=1, origin={"id"=>2, "parent_id"=>1}>], origin={"id"=>1, "parent_id"=>nil}>]
```

As a result, nodes are `OpenStruct` objects with initial fields `id`, `parent_id` and additional fields `level`, `origin` and `children`.

ActiveRecord objects can also serve as source nodes.




#### <a id="2.1.2"></a>Source data – ActiveRecord array [↑](#Оглавление "To the table of contents")

```rb
catalogs = Catalog.all.to_a
nested = catalogs.to_nested
puts nested.pretty_inspect
```

This will output:

```
[
  #<OpenStruct id=1, parent_id=nil, level=0, origin=#<Catalog id: 1, name: "Computer Components", parent_id: nil>, children=[
    #<OpenStruct id=11, parent_id=1, level=1, origin=#<Catalog id: 11, name: "External Components", parent_id: 1>, children=[
      #<OpenStruct id=111, parent_id=11, level=2, origin=#<Catalog id: 111, name: "Hard Drives", parent_id: 11>>,
      #<OpenStruct id=112, parent_id=11, level=2, origin=#<Catalog id: 112, name: "Sound Cards", parent_id: 11>>,
      #<OpenStruct id=113, parent_id=11, level=2, origin=#<Catalog id: 113, name: "KVM Switches", parent_id: 11>>,
      #<OpenStruct id=114, parent_id=11, level=2, origin=#<Catalog id: 114, name: "Optical Drives", parent_id: 11>>
    ]>,
    #<OpenStruct id=12, parent_id=1, level=1, origin=#<Catalog id: 12, name: "Internal Components", parent_id: 1>>
  ]>,
  #<OpenStruct id=2, parent_id=nil, level=0, origin=#<Catalog id: 2, name: "Monitors", parent_id: nil>>,
  #<OpenStruct id=3, parent_id=nil, level=0, origin=#<Catalog id: 3, name: "Servers", parent_id: nil>>,
  #<OpenStruct id=4, parent_id=nil, level=0, origin=#<Catalog id: 4, name: "Networking Products", parent_id: nil>>
]
```

<sub>The `.to_nested` method uses the `object.serializable_hash` method to get a list of the object's fields.</sub>




#### <a id="2.1.3"></a>`.to_nested` method options [↑](#Оглавление "To the table of contents")

##### <a id="2.1.3.1"></a>`root_id: id` [↑](#Оглавление "To the table of contents")

`root_id: 1` — take children of node with `id` equal to `1`.

```erb
<% catalogs_of_1 = Catalog.all.to_a.to_nested(root_id: 1) %>
<ul>
  <% catalogs_of_1.each_nested do |node, origin| %>
    <%= node.before -%>
    <%= origin.name -%> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after -%>
  <% end %>
</ul>
```

Will output a multi-level bulleted list of descendants of node #1:

![Screenshot](doc/images/2.1.3.1.png)




##### <a id="2.1.3.2"></a>`branch_id: id` [↑](#Оглавление "To the table of contents")

`branch_id: 1` — take the node with `id` equal to `1` and all its descendants.

```erb
<% catalogs_from_1 = Catalog.all.to_a.to_nested(branch_id: 1) %>
<ul>
  <% catalogs_from_1.each_nested do |node, origin| %>
    <%= node.before -%>
    <%= origin.name -%> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after -%>
  <% end %>
</ul>
```

Will output node #1 and its descendants:

![Screenshot](doc/images/2.1.3.2.png)


### <a id="2.2"></a>Displaying tree structures [↑](#Оглавление "To the table of contents")

#### <a id="2.2.1"></a>As multi-level lists [↑](#Оглавление "To the table of contents")

##### <a id="2.2.1.1"></a>Bulleted and numbered lists `<ul>`, `<ol>` [↑](#Оглавление "To the table of contents")

```erb
<ul>
  <% @catalogs.to_a.to_nested.each_nested do |node, origin| %>
    <%= node.before %>
    <%= link_to origin.name, origin %> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after %>
  <% end %>
</ul>

<ol>
  <% @catalogs.to_a.to_nested.each_nested ul: '<ol>', _ul: '</ol>' do |node, origin| %>
    <%= node.before %>
    <%= link_to origin.name, origin %> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after %>
  <% end %>
</ol>
```

![Screenshot](doc/images/2.2.1.1.png)




##### <a id="2.2.1.2"></a>Using your own templates to display a list [↑](#Оглавление "To the table of contents")

Instead of `<ul><li>`/`<ol><li>`

```erb
<% content_for :head do %>
  <style>
    /* Vertical node padding */
    div.li { margin: .5em 0; }
    /* Level indentation (children) */
    div.ul { margin-left: 2em; }
  </style>
<% end %>

<div class="ul">
  <%# Overriding opening and closing template tags. %>
  <% @catalogs.to_a.to_nested.each_nested(
    ul: '<div class="ul">',
    _ul: '</div>',
    li: '<div class="li">',
    _li: '</div>'
  ) do |node, origin| %>
    <%= node.before -%>
    <%= origin.name -%> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after -%>
  <% end %>
</div>
```

![Screenshot](doc/images/2.2.1.2.png)





##### <a id="2.2.1.3"></a>Changing the template depending on node data [↑](#Оглавление "To the table of contents")

To change the output patterns depending on the node data, we can check the node
fields `node.li` and `node.ul`. If the fields are not empty, then instead of
displaying their contents, substitute your own dynamic html.

Output of available node templates (`node.li`, `node.ul` and `node._`):

```erb
<ul>
  <% @catalogs.to_a.to_nested.each_nested do |node, origin| %>
    <%= node.li -%>
    <%= origin.name -%> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.ul -%>
    <%= node._ -%>
  <% end %>
</ul>
```

![Screenshot](doc/images/2.2.1.3-1.png)

Replacing templates with dynamic html:

```erb
<% content_for :head do %>
  <style>
    li.level-0 {color: red;}
    li.level-1 {color: green;}
    li.level-2 {color: blue;}
    li.has_children {font-weight: bold;}
    ul.big {border: solid 1px gray;}
  </style>
<% end %>

<ul>
  <% @catalogs.to_a.to_nested.each_nested do |node, origin| %>
    <li class="level-<%= node.level %> <%= 'has_children' if node.is_has_children %>">
    <%= origin.name %> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <% if node.ul.present? %>
      <ul class="<%= 'big' if node.children.length > 2 %>">
    <% end %>
    <%= node._ -%>
  <% end %>
</ul>
```

![Screenshot](doc/images/2.2.1.3-2.png)

It's worth noting that the `node.li` field is always present in a node, unlike
`node.ul`.




##### <a id="2.2.1.4"></a>Dropdown list based on `<details></details>` tag [↑](#Оглавление "To the table of contents")

```erb
<ul class="nested_array-details">
  <% @catalogs.to_a.to_nested.each_nested details: true do |node, origin| %>
    <%= node.before %>
    <%= origin.name %> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after %>
  <% end %>
</ul>
```

![Screenshot](doc/images/2.2.1.4-1.png)

By default, sublevels are hidden; you can control the display of sublevels by passing an option to the node method: `node.after(open: ...)`:

```erb
<ul class="nested_array-details">
  <% @catalogs.to_a.to_nested.each_nested details: true do |node, origin| %>
    <%= node.before %>
    <%= origin.name %> <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
    <%= node.after(open: node.is_has_children) %>
  <% end %>
</ul>
```

![Screenshot](doc/images/2.2.1.4-2.png)




##### <a id="2.2.1.5"></a>Formation and output of your own templates based on changing the node level `node.level` [↑](#Оглавление "To the table of contents")

```erb
<% content_for :head do %>
  <style>
    div.children {margin-left: 1em;}
    div.node {position: relative;}
    div.node::before {
      position: absolute;
      content: "";
      width: 0px;
      height: 0px;
      border-top: 5px solid transparent;
      border-bottom: 5px solid transparent;
      border-left: 8.66px solid red;
      left: -9px;
      top: 3px;
    }
  </style>
<% end %>

<div class="children">
  <% prev_level = nil %>
  <% @catalogs.to_a.to_nested.each_nested do |node, origin| %>

    <%# Has the level increased? - open the sublevel. %>
    <% if prev_level.present? && prev_level < node.level %>
      <div class="children">
    <% end %>

    <%# Same level? — we simply close the previous one. %>
    <% if prev_level.present? && prev_level == node.level %>
      </div>
    <% end %>

    <%# Has the level dropped? - closing the previous one is difficult. %>
    <% if prev_level.present? && prev_level > node.level %>
      <% (prev_level - node.level).times do |t| %>
        </div>
        </div>
      <% end %>
      </div>
    <% end %>

    <%# Our node. %>
    <div class="node">
    <%= origin.name %>

    <% prev_level = node.level %>
  <% end %>

  <%# Taking into account the previous level when exiting the cycle (Level has decreased). %>
  <% if !prev_level.nil? %>
    <% prev_level.times do |t| %>
      </div>
      </div>
    <% end %>
    </div>
  <% end %>
</div>
```

![Screenshot](doc/images/2.2.1.5.png)




#### <a id="2.2.2"></a>Pseudo-graphic output [↑](#Оглавление "To the table of contents")

##### <a id="2.2.2.1"></a>Adding pseudo-graphics before the model name using the `nested_to_options` method [↑](#Оглавление "To the table of contents")

```erb
<% options = @catalogs.to_a.to_nested.nested_to_options(:name, :id) %>
<pre><code><%= options.pluck(0).join($/) %>
</code></pre>
```

![Screenshot](doc/images/2.2.2.1.png)




##### <a id="2.2.2.2"></a>Thin pseudographics [↑](#Оглавление "To the table of contents")

```erb
<% options = @catalogs.to_a.to_nested.nested_to_options(:name, :id, thin_pseudographic: true) %>
<pre><code><%= options.pluck(0).join($/) %>
</code></pre>
```

![Screenshot](doc/images/2.2.2.2.png)




##### <a id="2.2.2.3"></a>Own pseudographics [↑](#Оглавление "To the table of contents")

```erb
<% options = @catalogs.to_a.to_nested.nested_to_options(:name, :id, pseudographics: %w(┬ ─ ❇ ├ └ &nbsp; │)) %>
<pre><code><%= options.pluck(0).join($/).html_safe %>
</code></pre>
```

![Screenshot](doc/images/2.2.2.3.png)




##### <a id="2.2.2.4"></a>Increase indentation in own pseudographics [↑](#Оглавление "To the table of contents")

```erb
<% options = @catalogs.to_a.to_nested.nested_to_options(:name, :id, pseudographics: ['─┬', '──', '─&nbsp;', '&nbsp;├', '&nbsp;└', '&nbsp;&nbsp;', '&nbsp;│']) %>
<pre><code><%= options.pluck(0).join($/).html_safe %>
</code></pre>
```

![Screenshot](doc/images/2.2.2.4.png)




#### <a id="2.2.3"></a>In html forms [↑](#Оглавление "To the table of contents")

#### <a id="2.2.3.1"></a>With the `form.select` helper [↑](#Оглавление "To the table of contents")

```erb
<%= form_with(model: Catalog.find(11), url: root_path, method: :get) do |form| %>
  <%= form.select :parent_id,
    @catalogs.to_a.to_nested.nested_to_options(:name, :id),
    {
      include_blank: 'None'
    },
    {
      multiple: false,
      size: 11,
      class: 'form-select form-select-sm nested_array-select'
    }
  %>
<% end %>
```

![Screenshot](doc/images/2.2.3.1.png)




#### <a id="2.2.3.2"></a>With `form.select` and `options_for_select` helpers [↑](#Оглавление "To the table of contents")

```erb
<%= form_with(model: Catalog.find(11), url: root_path, method: :get) do |form| %>
  <%= form.select :parent_id,
    options_for_select(
      @catalogs.to_a.to_nested.nested_to_options(:name, :id).unshift(['None', '']),
      selected: form.object.parent_id.to_s
    ),
    {
    },
    {
      multiple: false,
      size: 11,
      class: 'nested_array-select'
    }
  %>
<% end %>
```

![Screenshot](doc/images/2.2.3.2.png)




#### <a id="2.2.3.3"></a>Dropdown list with radio buttons `form.radio_button` [↑](#Оглавление "To the table of contents")

```erb
<%= form_with(model: nil, url: root_path, method: :get) do |form| %>
  <ul class="nested_array-details">
    <% @catalogs.to_a.to_nested.each_nested details: true do |node, origin| %>
      <%= node.before %>
      <%= form.radio_button :parent_id, origin.id %>
      <%= form.label :parent_id, origin.name, value: origin.id %>
      <small>[<%= origin.id %>, <%= origin.parent_id || :nil %>, <%= node.level %>]</small>
      <%= node.after(open: node.is_has_children) %>
    <% end %>
  </ul>
<% end %>
```

![Screenshot](doc/images/2.2.3.3.png)




## Development

To connect the local version of the gem, replace the second argument(version) in
the connection line (Gemfile file) with the path option:

```rb
# Working with tree arrays
gem "nested_array", path: "../nested_array"
```
