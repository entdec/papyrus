class Item < ApplicationRecord
  state_machine initial: :available do
    event :allocate do
      transition available: :allocated
    end

    event :unallocate do
      transition allocated: :available
    end
  end

  papyrable use_state_machine: true, life_cycle: true
end
