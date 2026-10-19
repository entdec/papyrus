require 'test_helper'

class PapyrusTableViewsTest < ActionView::TestCase
  self.fixture_table_names = []

  class Card
    attr_reader :tabs

    def initialize(view)
      @view = view
      @tabs = []
    end

    def with_tab(name, padding:, &block)
      @tabs << [name, padding, @view.capture(&block)]
    end
  end

  class Cards
    attr_reader :cards

    def initialize(view)
      @view = view
      @cards = []
    end

    def card(name, **options, &block)
      card = Card.new(@view)
      @cards << [name, options, card]
      content = @view.capture(card, &block)
      @view.safe_join([content, *card.tabs.map(&:last)])
    end
  end

  setup do
    @calls = []
    calls = @calls
    view = self.view
    @cards = Cards.new(view)
    cards = @cards
    view.define_singleton_method(:sts) { cards }
    view.define_singleton_method(:table) do |name, params:|
      calls << [name, params]
      content_tag(:div, name)
    end
    view.define_singleton_method(:templates_menu) { [] }
    view.define_singleton_method(:locales_menu) { [] }
  end

  test 'standalone cards render namespaced tables without padding' do
    %w[templates locales].each do |name|
      render template: "papyrus/admin/#{name}/index"
      assert_includes @calls, ["papyrus/#{name}", {}]
      assert_equal false, @cards.cards.last[1][:content_padding]
    end
  end

  test 'dashboard tabs preserve request scope parameters' do
    view.request.query_parameters.merge!('template_id' => 'template-123', 'papyrable_id' => 'item-123', 'papyrable_type' => 'Item')
    @papyrable = Object.new
    render template: 'papyrus/dashboard/show'
    assert_includes @calls, ['papyrus/papers', {'template_id' => 'template-123', 'papyrable' => @papyrable}]
    assert_includes @calls, ['papyrus/print_jobs', {}]
    assert_equal [[:papers, false], [:print_jobs, false]], @cards.cards.last.last.tabs.map { |name, padding, _| [name, padding] }
  end
end
