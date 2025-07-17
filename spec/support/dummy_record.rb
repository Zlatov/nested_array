# Имитация инстанса #ActiveRecord для проведения тестов.
class DummyRecord
  attr_accessor :id, :parent_id

  def initialize(id, parent_id)
    @id = id
    @parent_id = parent_id
  end

  def serializable_hash
    {
      'id' => id,
      'parent_id' => parent_id
    }
  end
end
