class Item < ApplicationRecord
  state_machine initial: :available do
    event :allocate do
      transition available: :allocated
    end

    event :unallocate do
      transition allocated: :available
    end
  end

  transaction_loggable
  papyrable use_state_machine: true, life_cycle: true
end
