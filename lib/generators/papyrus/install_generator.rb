module Papyrus
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def create_initializer_file
      template "config/initializers/papyrus.rb"
    end

    def add_route
      return if Rails.application.routes.routes.detect { |route| route.app.app == Papyrus::Engine }
      route %(mount Papyrus::Engine => "/papyrus")
    end

    def copy_migrations
      rake "papyrus:install:migrations"
    end

    def tailwindcss_config
      rake "papyrus:tailwindcss:config"
    end
  end
end
