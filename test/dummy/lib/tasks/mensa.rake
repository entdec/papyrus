# The engine's tables live outside Rails.root, where Mensa normally discovers
# host tables. Verify the shipped engine tables in this dummy application.
Rake::Task['mensa:verify_all'].clear_actions
Rake::Task['mensa:verify_all'].enhance do
  tables = Mensa::Verifier.table_classes(Papyrus::Engine.root.join('app/tables')).reject { |klass| klass == Papyrus::ApplicationTable }
  abort 'No Papyrus tables found' if tables.empty?
  exit(1) unless Mensa::Verifier.run(tables)
end
