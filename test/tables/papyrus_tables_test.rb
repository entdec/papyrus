require 'test_helper'
require 'mensa/testing'

class PapyrusTablesTest < ActiveSupport::TestCase
  self.fixture_table_names = %w[users papyrus/templates papyrus/computers papyrus/printers]

  TABLES = [Papyrus::LocalesTable, Papyrus::TemplatesTable, Papyrus::PapersTable, Papyrus::PrintJobsTable].freeze

  setup do
    Papyrus::PrintJob.delete_all
    Papyrus::Paper.destroy_all
    Papyrus::Locale.delete_all
    @template = papyrus_templates(:pdf_for_items)
    @owner = users(:one)
    @item = users(:two)
    @paper = Papyrus::Paper.create!(template: @template, owner: @owner, papyrable: @item, consolidation_id: 'batch-one')
    @paper.attachment.attach(io: StringIO.new('example'), filename: 'example.pdf', content_type: 'application/pdf')
    @other = Papyrus::Paper.create!(template: papyrus_templates(:zpl), consolidation_id: 'batch-two')
    Papyrus::PrintJob.create!(paper: @paper, printer: papyrus_printers(:one))
    Papyrus::PrintJob.create!(paper: @other, printer: papyrus_printers(:one))
    Papyrus::Locale.create!(key: 'en', metadata: {})
    Papyrus::Locale.create!(key: 'nl', metadata: {})
  end

  test 'every populated table passes the Mensa verifier in both languages' do
    [:en, :nl].each do |locale|
      I18n.with_locale(locale) do
        TABLES.each { |table| assert_mensa_table_valid table, user: @owner, strict: true }
        assert_mensa_table_valid Papyrus::PapersTable, params: {template_id: @template.id}, strict: true
        assert_mensa_table_valid Papyrus::PapersTable, params: {papyrable_type: 'User', papyrable_id: @item.id}, strict: true
      end
    end
  end

  test 'papers retain template and polymorphic parameter scopes' do
    assert_equal [@paper.id], Papyrus::PapersTable.new(params: {template_id: @template.id}).selected_scope.map(&:id)
    assert_equal [@paper.id], Papyrus::PapersTable.new(params: {papyrable: @item}).selected_scope.map(&:id)
    assert_equal [@paper.id], Papyrus::PapersTable.new(params: {papyrable_type: 'User', papyrable_id: @item.id}).selected_scope.map(&:id)
  end

  test 'selected records retain computed and association data' do
    table = Papyrus::TemplatesTable.new
    record = table.selected_scope.find(@template.id)
    assert_equal 1, record[:papers_count]
    papers = Papyrus::PapersTable.new.selected_scope.to_a
    assert_equal 2, papers.size
    assert_equal 'example.pdf', papers.find { |paper| paper.id == @paper.id }[:attachment]
    assert_equal @owner.name, papers.find { |paper| paper.id == @paper.id }.owner.name
    jobs = Papyrus::PrintJobsTable.new.selected_scope.to_a
    assert_equal 2, jobs.size
    assert_equal @template.description, jobs.find { |job| job.paper_id == @paper.id }[:paper]
    assert_equal papyrus_printers(:one).name, jobs.first[:printer_name]
  end

  test 'paper actions preserve visibility and default pagination is stable' do
    table = Papyrus::PapersTable.new
    attached = table.selected_scope.find(@paper.id)
    empty = table.selected_scope.find(@other.id)
    actions = table.actions.index_by(&:name)
    assert actions[:preview].show.call(attached)
    assert actions[:print].show.call(attached)
    assert actions[:regenerate].show.call(attached)
    assert actions[:print_consolidation].show.call(attached)
    refute actions[:preview].show.call(empty)
    refute actions[:print].show.call(empty)
    refute actions[:regenerate].show.call(empty)
    time = Time.current.change(usec: 0)
    @paper.update_columns(created_at: time)
    @other.update_columns(created_at: time)
    expected = [@paper.id, @other.id].sort.reverse
    assert_equal expected, Papyrus::PapersTable.new.selected_scope.map(&:id)
    assert_equal expected.reverse, Papyrus::PapersTable.new(order: {created_at: :asc}).selected_scope.map(&:id)
  end

  test 'metadata visibility scopes remain authoritative' do
    original = Papyrus.config.visible_scope
    Papyrus.config.visible_scope = -> { where(id: nil) }
    assert_empty Papyrus::TemplatesTable.new.selected_scope
    assert_empty Papyrus::LocalesTable.new.selected_scope
  ensure
    Papyrus.config.visible_scope = original
  end

  test 'model and displayed column translations exist explicitly in both languages' do
    [:en, :nl].each do |locale|
      TABLES.each do |klass|
        table = klass.new
        key = table.model.model_name.i18n_key
        [:one, :other].each do |plural|
          assert I18n.exists?("activerecord.models.#{key}.#{plural}", locale, fallback: false)
        end
        table.display_columns.each do |column|
          assert I18n.exists?("activerecord.attributes.#{key}.#{column.name}", locale, fallback: false), "#{locale}: #{key}.#{column.name}"
        end
      end
    end
    action = Papyrus::PapersTable.new.actions.find { |item| item.name == :preview }
    assert_equal 'Preview', I18n.with_locale(:en) { action.title }
    assert_equal 'Voorbeeld', I18n.with_locale(:nl) { action.title }
  end
end
