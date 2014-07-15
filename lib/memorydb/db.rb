require 'memorydb/base'
require 'memorydb/cursor'

module MemoryDb
  class Db < Base

    def initialize(model_klass, options={})
      @model_klass = model_klass
      @id = 0
      @store = {}
      @primary_key = options[:primary_key]
    end

    def create!(given={})
      _id = id
      attrs = model_or_hash_as_attrs(given)
      attributes = attrs.merge(primary_key => _id)
      store!(_id, attributes)
      return_model_or_hash(attributes)
    end

    def return_model_or_hash(attrs)
      if model_klass
        model_klass.new(attrs)
      else
        attrs
      end
    end

    def update!(model_or_id, attributes={})
      attributes ||= {}
      model_or_hash = case
                      when model_klass && model_or_id.is_a?(model_klass)
                        if model = find_by_id(model_or_id.send(primary_key))
                          model_or_id
                        else
                          raise ArgumentError.new("Could not update record with id: #{model_or_id.send(primary_key)} because it does not exist") unless model
                        end

                      else
                        if model = find_by_id(model_or_id)
                          model
                        else
                          raise ArgumentError.new("Could not update record with id: #{model_or_id} because it does not exist") unless model
                        end
                      end
      updated_attrs = model_or_hash_as_attrs(model_or_hash).merge(attributes_without_pkey(attributes))
      store!(model_or_hash[primary_key], updated_attrs)
      return_model_or_hash(updated_attrs)
    end

    def find_by_id(id)
      find.eq(primary_key, id).first
    end

    ###########################
    # These methods are called by the cursor. Do not call them directly. Or call them. Whatever. Either one.

    def raw_find(query)
      models = all_models
      models = apply_transforms models, query[:transforms]
      models = filter_models    models, query[:filters]
      models = sort_models      models, query[:sorts]
      models = offset_models    models, query[:offset]
      models = limit_models     models, query[:limit]
    end

    def execute_find(query)
      models = raw_find(query)
      if model_klass
        models.map { |h| model_klass.new(h) }
      else
        models
      end
    end

    def execute_count(query)
      execute_find(query).size
    end

    def execute_remove!(query)
      execute_find(query).each do |model|
        remove_model!(model)
      end
    end

    ###########################

    private

    attr_reader :primary_key

    def verify_attributes!(attrs)
      null_model = model_klass.new
      allowed_attributes = null_model.attributes.keys.map(&:to_sym)
      attrs.each do |key, value|
        unless allowed_attributes.include?(key.to_sym)
          raise ArgumentError.new("Unknown attribute: #{key}")
        end
      end
    end

    def attributes_without_pkey(attributes)
      attributes.reject { |k, v| k == primary_key }
    end

    def apply_transforms(models, transforms)
      models.map do |model|
        (transforms || []).reduce(model) do |model, transform|
          transform.call(model)
        end
      end
    end

    def filter_models(models, filters)
      models.select do |model|
        (filters || []).all? do |filter|
          filter_matches?(filter, model)
        end
      end
    end

    def filter_matches?(filter, hash)
      value = filter.field ? hash[filter.field] : nil
      case filter.operator
      when '='; value == filter.value
      when '!='; value != filter.value
      when '<'; value && (value < filter.value)
      when '<='; value && (value <= filter.value)
      when '>'; value && (value > filter.value)
      when '>='; value && (value >= filter.value)
      when 'contains'; value && value.include?(filter.value)
      when 'in'; filter.value.include?(value)
      when '!in'; !filter.value.include?(value)
      when 'or'; filter.value.any? do |sub_filter|
        filter_matches?(sub_filter, hash)
      end
      when 'and'; filter.value.all? do |sub_filter|
        filter_matches?(sub_filter, hash)
      end
      when 'not'; !filter_matches?(filter.value, hash)
      when 'like'; value =~ /#{filter.value}/i
      end
    end

    def sort_models(models, sorts)
      models.sort { |model1, model2| compare_models(model1, model2, sorts) }
    end

    def compare_models(model1, model2, sorts)
      sorts.each do |sort|
        result = compare_model(model1, model2, sort)
        return result if result
      end
      0
    end

    def compare_model(model1, model2, sort)
      field1, field2 = model1[sort.field], model2[sort.field]
      field1 == field2 ?  nil :
        (field1.nil? ? true : (field2.nil? ? false : (field1 < field2))) && sort.order == :asc  ?  -1  :
        (field1.nil? ? false : (field2.nil? ? true : (field1 > field2))) && sort.order == :desc ?  -1  : 1
    end

    def limit_models(models, limit)
      if limit
        models.take(limit)
      else
        models
      end
    end

    def offset_models(models, offset)
      if offset
        models.drop(offset)
      else
        models
      end
    end

    def all_models
      @store.values
    end

    def store!(id, attributes)
      @store[id] = attributes
    end

    def remove_model!(model)
      @store.delete(model[primary_key])
      nil
    end

    def id
      @id += 1
    end
  end
end
