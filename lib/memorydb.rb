require 'memorydb/db'

module MemoryDb

  def self.new(model_klass, options={})
    Db.new(model_klass, options)
  end

end
