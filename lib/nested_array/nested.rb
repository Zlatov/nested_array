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
      root_id: nil,

      # Параметры для преобразования в html
      tabulated: true,
      inline: false,
      tab: "\t",

      # Параматры для "склеивания" вложенных структур
      path_separator: '-=path_separator=-',
      path_key: 'text',

      # Настройки формирования массива для опций тега <select>
      option_value: 'id', # Что брать в качестве значений при формировании опций селекта.
      option_text: 'name',

      # Выводить html теги от раскрывающегося списка на основе тега details.
      details: false,

      ul:  '<ul>',
      _ul: '</ul>',
      li:  '<li>',
      _li: '</li>',

      uld:  '<details><summary></summary><ul>',
      uldo:  '<details open><summary></summary><ul>',
      _uld: '</ul></details>'
    }
  end

  def to_nested(options = {})
    options = NESTED_OPTIONS.merge options
    # Зарезервированные поля узла.
    fields = {
      id: options[:id],
      parent_id: options[:parent_id],
      level: options[:level],
      children: options[:children],
    }
    cache = {}
    nested = options[:hashed] ? {} : []
    # Перебираем элементы в любом порядке!
    self.each do |value|
      origin = value
      value = value.serializable_hash if !value.is_a? Hash
      # 1. Если нет родителя текущего элемента, и текущий элемент не корневой, то:
      # 1.1 создадим родителя
      # 1.2 поместим в кэш
      if !(cache.key? value[fields[:parent_id]]) && (value[fields[:parent_id]] != options[:root_id])
        # 1.1
        temp = OpenStruct.new
        temp[options[:id]] = value[options[:parent_id]]
        temp[options[:parent_id]] = nil
        # 1.2
        cache[value[fields[:parent_id]]] = temp
      end
      # 2. Если текущий элемент уже был создан, значит он был чьим-то родителем, тогда:
      # 2.1 обновим в нем информацию о parent_id и другие не зарезервированные поля.
      # 2.2 поместим в родителя
      if cache.key? value[fields[:id]]
        # 2.1
        cache[value[fields[:id]]][options[:parent_id]] = value[options[:parent_id]]
        value.keys.each do |field|
          if fields.keys.exclude? field.to_sym
            cache[value[fields[:id]]][field] = value[field]
          end
        end
        cache[value[fields[:id]]].origin = origin
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
        temp = OpenStruct.new
        temp[options[:id]] = value[options[:id]]
        temp[options[:parent_id]] = value[options[:parent_id]]
        value.keys.each do |field|
          if fields.keys.exclude? field.to_sym
            temp[field] = value[field]
          end
        end
        temp.origin = origin
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

    # Добавление level к узлу.
    level = 0
    cache = []
    cache[level] = nested
    i = []
    i[level] = 0
    while level >= 0
      node = cache[level][i[level]]
      i[level] += 1
      if node != nil

        node[options[:level]] = level

        if !node[options[:children]].nil? && node[options[:children]].length > 0
          level += 1
          cache[level] = node[options[:children]]
          i[level] = 0
        end
      else
        level -= 1
      end
    end

    nested
  end

  # 
  # Перебирает вложенную стуктуру.
  # 
  def each_nested(options = {})
    options = NESTED_OPTIONS.merge options
    level = 0
    cache = []
    cache[level] = self.clone
    parents = []
    parents[level] = nil
    i = []
    i[level] = 0
    prev_level = nil
    while level >= 0
      node = cache[level][i[level]]
      i[level] += 1
      if node != nil
        clone_node = node.clone

        # Текущий узел является последним ребёнком своего родителя:
        clone_node.is_last_children = cache[level][i[level]].blank?
        # Текущий узел имеет детей:
        clone_node.is_has_children = !node[options[:children]].nil? && node[options[:children]].length > 0
        # Текущий узел последний в дереве:
        clone_node.is_last = clone_node.is_last_children && !clone_node.is_has_children && (0..(clone_node.level)).to_a.map{|l| cache[l][i[l]].blank?}.all?(true)

        next_level = if clone_node.is_has_children
          level + 1
        elsif clone_node.is_last_children
          nl = nil
          (0..clone_node.level).to_a.reverse.each do |l|
            if cache[l][i[l]].present?
              nl = l
              break
            end
          end
          nl
        else
          level
        end

        clone_node.parents = parents.clone

        # В текущем узле всегда есть li
        clone_node.before = options[:li].html_safe
        clone_node.li = clone_node.before
        # Следующий уровень тот же? — текущий закрываем просто.
        if next_level.present? && next_level == clone_node.level
          clone_node._ = options[:_li].html_safe
        end
        # Следующий уровень понизится? - текущий закрываем сложно.
        if next_level.present? && next_level < clone_node.level
          clone_node._ = options[:_li]
          (clone_node.level - next_level).times do |t|
            clone_node._ += options[:details] ? options[:_uld] + options[:_li] : options[:_ul] + options[:_li]
          end
          clone_node._ = clone_node._.html_safe
        end
        # Следующий уровень повысится? — открываем подуровень.
        if clone_node.is_has_children
          clone_node.ul = if options[:details]
            options[:uld].html_safe
          else
            options[:ul].html_safe
          end
        end
        # Последний в дереве? — последние закрывающие теги.
        if clone_node.is_last
          clone_node._ = options[:_li]
          clone_node.level.times do |t|
            clone_node._ += options[:details] ? options[:_uld] + options[:_li] : options[:_ul] + options[:_li]
          end
          clone_node._ = clone_node._.html_safe
        end

        clone_node.define_singleton_method(:after) do |*args|
          ret = ''
          # Следующий уровень тот же? — текущий закрываем просто.
          if next_level.present? && next_level == clone_node.level
            ret += options[:_li]
          end
          # Следующий уровень понизится? - текущий закрываем сложно.
          if next_level.present? && next_level < clone_node.level
            ret += options[:_li]
            (clone_node.level - next_level).times do |t|
              ret += options[:details] ? options[:_uld] + options[:_li] : options[:_ul] + options[:_li]
            end
          end
          # Следующий уровень повысится? — открываем подуровень.
          if self.is_has_children
            if options[:details]
              ret += args.present? && args[0]&.[](:open) == true ? options[:uldo] : options[:uld]
            else
              ret += options[:ul]
            end
          end
          # Последний в дереве? — последние закрывающие теги.
          if self.is_last
            ret += options[:_li]
            self.level.times do |t|
              ret += options[:details] ? options[:_uld] + options[:_li] : options[:_ul] + options[:_li]
            end
          end
          ret.html_safe
        end

        yield(clone_node, clone_node.origin)

        prev_level = node.level

        if !node[options[:children]].nil? && node[options[:children]].length > 0
          level += 1
          parents[level] = clone_node
          cache[level] = node[options[:children]]
          i[level] = 0
        end
      else
        parents[level] = nil
        level -= 1
      end
    end
    self
  end

  def to_flat(options = {})
    ret = []
    options = NESTED_OPTIONS.merge options
    level = 0
    cache = []
    cache[level] = self.clone
    i = []
    i[level] = 0
    while level >= 0
      node = cache[level][i[level]]
      i[level] += 1
      if node != nil
        ret.push node.origin

        if !node[options[:children]].nil? && node[options[:children]].length > 0
          level += 1
          cache[level] = node[options[:children]]
          i[level] = 0
        end
      else
        level -= 1
      end
    end
    ret
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
    # each_nested do |node, parents, level, is_last|
    each_nested do |node, origin|
      last[node.level + 1] = node.is_last_children
      node_text = node[options[:option_text]]
      node_level = (1..node.level).map{|l| last[l] == true ? '&nbsp;' : '┃'}.join
      node_last = node.is_last_children ? '┗' : '┣'
      node_children = node[options[:children]].present? && node[options[:children]].length > 0 ? '┳' : '━'
      option_text = "#{node_level}#{node_last}#{node_children}╸".html_safe + "#{node_text}"
      option_value = node[options[:option_value]]
      ret.push [option_text, option_value]
    end
    ret
  end

  # Преобразует вложенную структуру данных в плоскую, но добавляет в значение
  # поля отвечающего за текстовое представление (:name) псевдографику
  # древовидной структуры.
  # Это позволяет вывести тэг select в сносном виде для использования с
  # вложенными структурами.
  def nested_to_collection_select(options={})
    options = NESTED_OPTIONS.merge options
    ret = []
    last = []
    each_nested do |node, parents, level, is_last, origin|
      last[level+1] = is_last
      node_text = node[options[:option_text]]
      node_level = (1..level).map{|l| last[l] == true ? '&nbsp;' : '┃'}.join
      node_last = is_last ? '┗' : '┣'
      node_children = node[options[:children]].present? && node[options[:children]].length > 0 ? '┳' : '━'
      option_text = "#{node_level}#{node_last}#{node_children}╸".html_safe + "#{node_text}"
      option_value = node[options[:option_value]]
      node[options[:option_text]] = option_text
      ret.push node
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
