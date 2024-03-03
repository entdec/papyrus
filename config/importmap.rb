pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "papyrus", to: "papyrus/application.js", preload: false
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin_all_from Papyrus::Engine.root.join("app/javascript/papyrus/controllers"), under: "papyrus/controllers", to: "papyrus/controllers", preload: false
