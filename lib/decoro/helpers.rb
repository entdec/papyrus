# frozen_string_literal: true

module Decoro
  module Helpers
    def decorate(model, decorator_class = nil)
      array = nil
      if model.is_a? Array
        array = model
        model = model.first
      end

      klass = decorator_class || "#{model.class}Decorator".constantize
      decorator = array ? array.map { |m| klass.new(m) } : klass.new(model)
      yield(decorator) if block_given?
    end
  end
end
