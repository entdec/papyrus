# frozen_string_literal: true

module Papyrus
  class ApplicationTable < Mensa::Base
    # User-selected orders can contain ties. Keep pagination deterministic.
    def ordered_scope
      @stable_ordered_scope ||= super.order(model.arel_table[:id].asc)
    end
  end
end
