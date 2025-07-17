# Определим класс Engine только если гем используется в окружении Rails
# (например, в приложении Ruby on Rails).
#
# Это позволяет использовать ассеты гема (например, CSS) в Rails-приложении,
# но при этом не мешает запускать тесты RSpec вне Rails-среды.
if defined?(Rails)
  module NestedArray
    class Engine < ::Rails::Engine
    end
  end
end
