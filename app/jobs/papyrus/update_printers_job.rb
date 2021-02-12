module Papyrus
  class UpdatePrintersJob < ApplicationJob
    def perform(user, printers_list); end
  end
end
