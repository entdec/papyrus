# frozen_string_literal: true

require 'slim'
require 'tailwindcss-rails'
require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

module Papyrus
  class Engine < ::Rails::Engine
    isolate_namespace Papyrus

    initializer 'papyrus.assets' do |app|
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.paths << root.join("app/components")
      app.config.assets.paths << Papyrus::Engine.root.join("vendor/javascript")
      app.config.assets.precompile += %w[papyrus_manifest]
    end

    initializer 'papyrus.importmap', before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
      app.config.importmap.cache_sweepers << root.join("app/components")
      app.config.importmap.cache_sweepers << Papyrus::Engine.root.join("vendor/javascript")
    end
    
    initializer 'papyrus.config' do |_app|
      path = File.expand_path(File.join(File.dirname(__FILE__), '.', 'liquid', '{tags,filters}', '*.rb'))
      Dir.glob(path).each do |c|
        require_dependency(c)
      end
    end
    
    initializer 'active_storage.attached' do
      config.after_initialize do
        ActiveSupport.on_load(:active_record) do
          Papyrus::Template.include(AttachmentsHelpers)
          Papyrus::Paper.include(AttachmentHelpers)
        end
      end
    end
  end
end
