# -*- encoding: utf-8 -*-
# stub: papyrus 1.1.32 ruby lib

Gem::Specification.new do |s|
  s.name = "papyrus".freeze
  s.version = "1.1.32"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tom de Grunt".freeze]
  s.date = "2021-12-29"
  s.description = "Paperwork generation in several output formats".freeze
  s.email = ["tom@degrunt.nl".freeze]
  s.files = ["MIT-LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "app/assets/config/papyrus_manifest.js".freeze, "app/assets/images/papyrus".freeze, "app/assets/stylesheets/papyrus".freeze, "app/assets/stylesheets/papyrus/application.css".freeze, "app/channels".freeze, "app/channels/papyrus".freeze, "app/channels/papyrus/application_cable".freeze, "app/channels/papyrus/application_cable/channel.rb".freeze, "app/channels/papyrus/application_cable/connection.rb".freeze, "app/channels/papyrus/print_channel.rb".freeze, "app/controllers/papyrus".freeze, "app/controllers/papyrus/admin".freeze, "app/controllers/papyrus/admin/locales_controller.rb".freeze, "app/controllers/papyrus/admin/templates".freeze, "app/controllers/papyrus/admin/templates/attachments_controller.rb".freeze, "app/controllers/papyrus/admin/templates_controller.rb".freeze, "app/controllers/papyrus/api".freeze, "app/controllers/papyrus/api/events_controller.rb".freeze, "app/controllers/papyrus/application_admin_controller.rb".freeze, "app/controllers/papyrus/application_controller.rb".freeze, "app/controllers/papyrus/dashboard_controller.rb".freeze, "app/controllers/papyrus/papers_controller.rb".freeze, "app/controllers/papyrus/print_client_licenses_controller.rb".freeze, "app/controllers/papyrus/print_jobs_controller.rb".freeze, "app/controllers/papyrus/templates_controller.rb".freeze, "app/decorators".freeze, "app/decorators/papyrus".freeze, "app/decorators/papyrus/application_decorator.rb".freeze, "app/decorators/papyrus/template_decorator.rb".freeze, "app/drops".freeze, "app/drops/papyrus".freeze, "app/drops/papyrus/application_drop.rb".freeze, "app/drops/papyrus/paper_drop.rb".freeze, "app/generators".freeze, "app/generators/papyrus".freeze, "app/generators/papyrus/base_generator.rb".freeze, "app/generators/papyrus/custom_generator.rb".freeze, "app/helpers/papyrus".freeze, "app/helpers/papyrus/application_helper.rb".freeze, "app/jobs/papyrus".freeze, "app/jobs/papyrus/application_job.rb".freeze, "app/jobs/papyrus/generate_job.rb".freeze, "app/jobs/papyrus/update_printers_job.rb".freeze, "app/models/papyrus".freeze, "app/models/papyrus/application_record.rb".freeze, "app/models/papyrus/concerns".freeze, "app/models/papyrus/concerns/metadata.rb".freeze, "app/models/papyrus/concerns/metadata_scoped.rb".freeze, "app/models/papyrus/locale.rb".freeze, "app/models/papyrus/paper.rb".freeze, "app/models/papyrus/preferred_printer.rb".freeze, "app/models/papyrus/print_job.rb".freeze, "app/models/papyrus/printer.rb".freeze, "app/models/papyrus/template.rb".freeze, "app/services".freeze, "app/services/papyrus".freeze, "app/services/papyrus/application_context.rb".freeze, "app/services/papyrus/application_service.rb".freeze, "app/tables/papyrus_locales_table.rb".freeze, "app/tables/papyrus_papers_table.rb".freeze, "app/tables/papyrus_print_jobs_table.rb".freeze, "app/tables/papyrus_templates_table.rb".freeze, "app/views/papyrus".freeze, "app/views/papyrus/_printers.html.slim".freeze, "app/views/papyrus/admin".freeze, "app/views/papyrus/admin/locales".freeze, "app/views/papyrus/admin/locales/edit.html.slim".freeze, "app/views/papyrus/admin/locales/index.html.slim".freeze, "app/views/papyrus/admin/templates".freeze, "app/views/papyrus/admin/templates/attachments".freeze, "app/views/papyrus/admin/templates/attachments/_attachments.html.slim".freeze, "app/views/papyrus/admin/templates/attachments/_index.html.slim".freeze, "app/views/papyrus/admin/templates/attachments/create.json.jbuilder".freeze, "app/views/papyrus/admin/templates/edit.html.slim".freeze, "app/views/papyrus/admin/templates/index.html.slim".freeze, "app/views/papyrus/dashboard".freeze, "app/views/papyrus/dashboard/show.html.slim".freeze, "app/views/papyrus/papers".freeze, "app/views/papyrus/papers/show.html.slim".freeze, "config/locales".freeze, "config/locales/en.yml".freeze, "config/routes.rb".freeze, "db/migrate".freeze, "db/migrate/20200307000050_pg_fix.rb".freeze, "db/migrate/20200307131650_create_papyrus_templates.rb".freeze, "db/migrate/20200309135928_add_example_data_to_papyrus_template.rb".freeze, "db/migrate/20200309150516_create_papyrus_locales.rb".freeze, "db/migrate/20200311190329_create_papyrus_papers.rb".freeze, "db/migrate/20210217144536_create_papyrus_printing.rb".freeze, "db/migrate/20210223183635_add_enabled_to_papyrus_template.rb".freeze, "db/migrate/20210314164330_add_kind_to_paper.rb".freeze, "db/migrate/20210321115006_add_use_to_papyrus_paper.rb".freeze, "db/migrate/20210322093957_change_papyrus_papers.rb".freeze, "db/migrate/20210921101620_add_purpose_to_paper_and_template.rb".freeze, "db/migrate/20211228085943_add_condition_to_template.rb".freeze, "lib/papyrus".freeze, "lib/papyrus.rb".freeze, "lib/papyrus/active_record_helpers.rb".freeze, "lib/papyrus/attachment_helpers.rb".freeze, "lib/papyrus/attachments_helpers.rb".freeze, "lib/papyrus/configuration.rb".freeze, "lib/papyrus/context.rb".freeze, "lib/papyrus/deprecator.rb".freeze, "lib/papyrus/engine.rb".freeze, "lib/papyrus/i18n_store.rb".freeze, "lib/papyrus/liquid".freeze, "lib/papyrus/liquid/filters".freeze, "lib/papyrus/liquid/filters/image_magic_filter.rb".freeze, "lib/papyrus/liquid/tags".freeze, "lib/papyrus/papyrable.rb".freeze, "lib/papyrus/prawn_extensions.rb".freeze, "lib/papyrus/shash.rb".freeze, "lib/papyrus/state_machine.rb".freeze, "lib/papyrus/transactio.rb".freeze, "lib/papyrus/version.rb".freeze]
  s.homepage = "https://code.entropydecelerator.com/components/papyrus".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Paperwork generation".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<barby>.freeze, ["~> 0.6"])
    s.add_runtime_dependency(%q<decoro>.freeze, ["~> 0.1"])
    s.add_runtime_dependency(%q<evento>.freeze, ["~> 0.1"])
    s.add_runtime_dependency(%q<img2zpl>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<labelary>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<liquor>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<pg>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<prawn>.freeze, ["~> 2.2"])
    s.add_runtime_dependency(%q<prawn-svg>.freeze, ["~> 0.29"])
    s.add_runtime_dependency(%q<prawn-table>.freeze, ["~> 0.2"])
    s.add_runtime_dependency(%q<rails>.freeze, ["~> 6.0", ">= 6.0.2.1"])
    s.add_runtime_dependency(%q<rqrcode>.freeze, ["~> 0.10"])
    s.add_runtime_dependency(%q<servitium>.freeze, ["~> 1.1"])
    s.add_runtime_dependency(%q<state_machines-activemodel>.freeze, ["~> 0.8"])
    s.add_runtime_dependency(%q<tilt>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<transactio>.freeze, [">= 0"])
    s.add_development_dependency(%q<auxilium>.freeze, ["~> 0.2"])
    s.add_development_dependency(%q<pdf-inspector>.freeze, [">= 1.2.1", "< 2.0.a"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0.11"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0"])
  else
    s.add_dependency(%q<barby>.freeze, ["~> 0.6"])
    s.add_dependency(%q<decoro>.freeze, ["~> 0.1"])
    s.add_dependency(%q<evento>.freeze, ["~> 0.1"])
    s.add_dependency(%q<img2zpl>.freeze, [">= 0"])
    s.add_dependency(%q<labelary>.freeze, [">= 0"])
    s.add_dependency(%q<liquor>.freeze, [">= 0"])
    s.add_dependency(%q<pg>.freeze, [">= 0"])
    s.add_dependency(%q<prawn>.freeze, ["~> 2.2"])
    s.add_dependency(%q<prawn-svg>.freeze, ["~> 0.29"])
    s.add_dependency(%q<prawn-table>.freeze, ["~> 0.2"])
    s.add_dependency(%q<rails>.freeze, ["~> 6.0", ">= 6.0.2.1"])
    s.add_dependency(%q<rqrcode>.freeze, ["~> 0.10"])
    s.add_dependency(%q<servitium>.freeze, ["~> 1.1"])
    s.add_dependency(%q<state_machines-activemodel>.freeze, ["~> 0.8"])
    s.add_dependency(%q<tilt>.freeze, ["~> 2.0"])
    s.add_dependency(%q<transactio>.freeze, [">= 0"])
    s.add_dependency(%q<auxilium>.freeze, ["~> 0.2"])
    s.add_dependency(%q<pdf-inspector>.freeze, [">= 1.2.1", "< 2.0.a"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.11"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0"])
  end
end
