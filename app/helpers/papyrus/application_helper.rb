# frozen_string_literal: true

module Papyrus
  module ApplicationHelper
    def templates_menu
      Satis::Menus::Builder.build(:sidebar) do |m|
        m.item :new, link: papyrus.new_admin_template_path
      end
    end

    def locales_menu
      Satis::Menus::Builder.build(:sidebar) do |m|
        m.item :new, link: papyrus.new_admin_locale_path
      end
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
