class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Liquor::ToLiquid
end
