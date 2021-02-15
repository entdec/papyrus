# frozen_string_literal: true

module Papyrus
  class ApplicationContext < Servitium::Context
    # Allow user to be given to any context, this enables us to carry over the user for asynchronously executed services
    attribute :user, type: User, default: -> { Current.user }, typecaster: lambda { |value|
      return nil if value.nil?
      return value if value.is_a?(User)

      User.find(value)
    }
  end
end
