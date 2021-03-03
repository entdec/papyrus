class UserDrop < ApplicationDrop
  delegate :name, to: :@object
end
