# frozen_string_literal: true

module Papyrus
  class Engine < ::Rails::Engine
    isolate_namespace Papyrus

    initializer 'papyrus.config' do |_app|
      path = File.expand_path(File.join(File.dirname(__FILE__), '.', 'liquid', '{tags,filters}', '*.rb'))
      Dir.glob(path).each do |c|
        require_dependency(c)
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match? root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
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
