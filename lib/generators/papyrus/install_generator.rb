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

    def add_content_to_tailwind_config
      inject_into_file "config/tailwind.config.js", before: "],\n  theme: {" do
        "  // Papyrus content\n" +
          %w[/app/views/**/* /app/helpers/**/* /app/controllers/**/* /app/components/**/* /app/javascript/**/*.js /app/assets/**/papyrus.css].map { |path| "    \"#{Papyrus::Engine.root}#{path}\"" }.join(",\n") +
          ",\n  "
      end
    end

    def add_content_application_tailwind_css
      inject_into_file "app/assets/stylesheets/application.tailwind.css", before: "@tailwind base;" do
        "@import '#{Papyrus::Engine.root}/app/assets/stylesheets/papyrus/papyrus.css';\n"
      end
    end
  end
end
