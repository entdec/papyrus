# frozen_string_literal: true

module Decoro
  module Helpers
    def decorate(model, decorator_class = nil)
      array = nil
      klass = decorator_class
      if model.is_a? Array
        array = model
        model = model.first
        klass ||= "#{model.class}Decorator".constantize
      elsif model.is_a? ActiveRecord::Relation
        klass ||= "#{model.name.pluralize}Decorator".constantize
      end

      decorator = array ? array.map { |m| klass.new(m) } : klass.new(model)
      yield(decorator) if block_given?
    end
  end
end
