module NestedArray::Nested

  class Error < StandardError
  end

  extend ActiveSupport::Concern

  included do |recipient|

    NESTED_OPTIONS ||= {
      # Имена полей для получения/записи информации, чувствительны к string/symbol
      id: 'id',
      parent_id: 'parent_id',
      children: 'children',
      level: 'level',

      # Параметры для преобразования в nested
      hashed: false,
      add_level: false,
      root_id: nil,

      # Параметры для преобразования в html
      tabulated: true,
      inline: false,
      tab: "\t",
      ul:  '<ul>',
      _ul: '</ul>',
      li:  '<li>',
      _li: '</li>',

      # Параматры для "склеивания" вложенных структур
      path_separator: '-=path_separator=-',
      path_key: 'text',

      # Настройки формирования массива для опций тега <select>
      option_value: 'id', # Что брать в качестве значений при формировании опций селекта.
      option_text: 'name',
    }
  end

  def each_nested options={}
    options = NESTED_OPTIONS.merge options
    level = 0
    cache = []
    cache[level] = self.clone
    parents = []
    parents[level] = nil
    i = []
    i[level] = 0
    while level >= 0
      node = cache[level][i[level]]
      i[level]+= 1
      if node != nil
        is_last_children = cache[level][i[level]].blank?

        yield(node.clone, parents.clone, level, is_last_children)

        if !node[options[:children]].nil? && node[options[:children]].length > 0
          level+= 1
          parents[level] = node.clone
          cache[level] = node[options[:children]]
          i[level] = 0
        end
      else
        parents[level] = nil
        level-= 1
      end
    end
    self
  end

  def each_nested! options={}
    options = NESTED_OPTIONS.merge options
    level = 0
    cache = []
    cache[level] = self
    parents = []
    parents[level] = nil
    i = []
    i[level] = 0
    while level >= 0
      node = cache[level][i[level]]
      i[level]+= 1
      if node != nil

        yield(node, parents, level)

        if !node[options[:children]].nil? && node[options[:children]].length > 0
          level+= 1
          parents[level] = node
          cache[level] = node[options[:children]]
          i[level] = 0
        end
      else
        parents[level] = nil
        level-= 1
      end
    end
    self
  end

  def to_nested options={}
    options = NESTED_OPTIONS.merge options
    fields = {
      id: options[:id],
      parent_id: options[:parent_id],
      level: options[:level],
      children: options[:children],
    }
    fields.delete :level if !options[:add_level]
    cache = {}
    nested = options[:hashed] ? {} : []
    # Перебираем элементы в любом порядке!
    self.each do |value|
      value = value.serializable_hash if !value.is_a? Hash
      # 1. Если нет родителя текущего элемента, и текущий элемент не корневой, то:
      # 1.1 создадим родителя
      # 1.2 поместим в кэш
      if !(cache.key? value[fields[:parent_id]]) && (value[fields[:parent_id]] != options[:root_id])
        # 1.1
        temp = {}
        fields.each do |key, field|
          case key
          when :id
            temp[field] = value[fields[:parent_id]]
          when :children
            # не создаём поле
          else
            temp[field] = nil
          end
        end
        # 1.2
        cache[value[fields[:parent_id]]] = temp
      end
      # 2. Если текущий элемент уже был создан, значит он был чьим-то родителем, тогда:
      # 2.1 обновим в нем информацию
      # 2.2 поместим в родителя
      if cache.key? value[fields[:id]]
        # 2.1
        fields.each do |key, field|
          case key
          when :id, :children
            # не обновляем информацию
          else
            cache[value[fields[:id]]][field] = value[field]
          end
        end
        value.keys.each do |field|
          cache[value[fields[:id]]][field] = value[field] if !(field.in? fields)
        end
        # 2.2
        # Если текущий элемент не корневой - поместим в родителя, беря его из кэш
        if value[fields[:parent_id]] != options[:root_id]
          cache[value[fields[:parent_id]]][fields[:children]] ||= options[:hashed] ? {} : []
          if options[:hashed]
            cache[value[fields[:parent_id]]][fields[:children]][value[fields[:id]]] = nested[value[fields[:id]]]
          else
            cache[value[fields[:parent_id]]][fields[:children]] << cache[value[fields[:id]]]
          end
        # иначе, текущий элемент корневой, поместим в nested
        else
          if options[:hashed]
            nested[value[fields[:id]]] = cache[value[fields[:id]]]
          else
            nested << cache[value[fields[:id]]]
          end
        end
      # 3. Иначе, текущий элемент не создан, тогда:
      # 3.1 создадим элемент
      # 3.2 поместим в кэш
      # 3.3 поместим в родителя
      else
        # 3.1
        temp = {}
        fields.each do |key, field|
          case key
          when :id
            temp[field] = value[field]
          when :parent_id
            temp[field] = value[field]
          when :children
            # ничего не делаем
          else
            temp[field] = value[field]
          end
        end
        value.keys.each do |field|
          temp[field] = value[field] if !(field.in? fields)
        end
        # 3.2
        cache[value[fields[:id]]] = temp
        # 3.3
        # Если текущий элемент не корневой - поместим в родителя, беря его из кэш
        if value[fields[:parent_id]] != options[:root_id]
          cache[value[fields[:parent_id]]][fields[:children]] ||= options[:hashed] ? {} : []
          if options[:hashed]
            cache[value[fields[:parent_id]]][fields[:children]][value[fields[:id]]] = cache[value[fields[:id]]]
          else
            cache[value[fields[:parent_id]]][fields[:children]] << cache[value[fields[:id]]]
          end
        # иначе, текущий элемент корневой, поместим в nested
        else
          if options[:hashed]
            nested[value[fields[:id]]] = cache[value[fields[:id]]]
          else
            nested << cache[value[fields[:id]]]
          end
        end
      end
    end
    if options[:add_level]
      level = 0
      cache = []
      cache[level] = nested
      i = []
      i[level] = 0
      while level >= 0
        node = cache[level][i[level]]
        i[level]+= 1
        if node != nil

          node[options[:level]] = level

          if !node[options[:children]].nil? && node[options[:children]].length > 0
            level+= 1
            cache[level] = node[options[:children]]
            i[level] = 0
          end
        else
          level-= 1
        end
      end
    end
    nested
  end

  def nested_to_html options={}
    options = NESTED_OPTIONS.merge options
    html = ''
    level = 0
    cache = []
    cache[level] = self.clone
    parents = []
    parents[level] = nil
    i = []
    i[level] = 0
    while level >= 0
      node = cache[level][i[level]]
      i[level]+= 1
      if node != nil

        html+= options[:tab] * (level * 2 + 1) if options[:tabulated]
        html+= options[:li]
        html+= yield(node.clone, parents.clone, level)

        if !node[options[:children]].nil? && node[options[:children]].length > 0
          level+= 1
          html+= "\n" if !options[:inline]
          html+= options[:tab] * (level * 2) if options[:tabulated]
          html+= options[:ul]
          html+= "\n" if !options[:inline]
          parents[level] = node.clone
          cache[level] = node[options[:children]]
          i[level] = 0
        else
          html+= options[:_li]
          html+= "\n" if !options[:inline]
        end
      else
        parents[level] = nil
        if level > 0
          html+= options[:tab] * (level * 2) if options[:tabulated]
          html+= options[:_ul]
          html+= "\n" if !options[:inline]
          html+= options[:tab] * (level * 2 - 1) if options[:tabulated]
          html+= options[:_li]
          html+= "\n" if !options[:inline]
        end
        level-= 1
      end
    end
    html.html_safe
  end

  # 
  # Возвращает массив для формирования опций html-тега <select>
  # с псевдографикой, позволяющей вывести древовидную структуру.
  # ```
  # [['option_text1', 'option_value1'],['option_text2', 'option_value2'],…]
  # ```
  def nested_to_options options={}
    options = NESTED_OPTIONS.merge options
    ret = []
    last = []
    each_nested do |node, parents, level, is_last|
      last[level+1] = is_last
      node_text = node[options[:option_text]]
      node_level = (1..level).map{|l| last[l] == true ? ' ' : '┃'}.join
      node_last = is_last ? '┗' : '┣'
      node_children = node[options[:children]].present? && node[options[:children]].length > 0 ? '┳' : '━'
      option_text = "#{node_level}#{node_last}#{node_children}╸#{node_text}"
      option_value = node[options[:option_value]]
      ret.push [option_text, option_value]
    end
    ret
  end

  # "Скеивание" вложенных структур
  # ноды склеиваются если путь к ним одинаков;
  # путь определяется из сложения Текстов (конфигурируемо через :path_key);
  def concat_nested tree=nil, options={}
    options = NESTED_OPTIONS.merge options
    return self if tree.nil?
    children_cache = {}
    tree.each_nested options do |node, parents, level|
      parent_path_names = parents.compact.map{|e| e[options[:path_key]]}
      parent_path = parent_path_names.join(options[:path_separator])
      path = parent_path_names.push(node[options[:path_key]]).join(options[:path_separator])
      element = node
      if !children_cache.keys.include? path
        if parent_path == ''
          array = self
        else
          array = children_cache[parent_path]
        end
        element[options[:children]] = []
        array << element
        children_cache[parent_path] = array
        children_cache[path] = element[options[:children]]
      end
    end
    self
  end
end
