# frozen_string_literal: true

module Papyrus
  module ApplicationHelper
    def templates_context_menu
      @templates_context_menu ||= Electio::Menu.new(context: self) do |menu|
        menu.item :new, link: new_admin_template_path
      end
      @templates_context_menu.for_context
    end

    def locales_context_menu
      @locales_context_menu ||= Electio::Menu.new(context: self) do |menu|
        menu.item :new, link: new_admin_locale_path
      end
      @locales_context_menu.for_context
    end

    def method_missing(method, *args, &block)
      if main_app.respond_to?(method)
        main_app.send(method, *args)
      else
        super
      end
    end
  end
end
