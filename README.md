# Papyrus

Paper generation based on templates. Web-based printing using print-client.

## Usage

The context of the templates will using Liquid Drops, and call `to_liquid` on your objects.
In case you want web-printing, the params needs an owner and possibly a locale. Use `default_params` on the
configuration object to set the owner or locale of a document.

```ruby
# config/initializers/papyrus.rb
config.default_params = lambda { |_event, _record|
  {owner: Current.user, locale: I18n.locale}
}
```

Install the PrintNode app: https://www.printnode.com/en

Print anything this way

```ruby
`Papyrus::Paper.new(kind: 'pdf', use: 'document', purpose: 'packlist', owner: User.first, attachment: {io: StringIO.new("test"), filename: 'test.pdf'}).print!`
```

or, for ZPL labels for example:

```ruby
Papyrus::Paper.new(kind: 'liquid', use: 'label', purpose: 'whatever', owner: User.first, attachment: {io: StringIO.new("^XA^BY5,2,270^FO100,50^BC^FD12345678^FS^XZ"), filename: 'test.zpl'}).print!
```

## Print job consolidation

You can consolidate print jobs by using the `consolidate` option. This will create a single print job for all the papers
that have the same `consolidation_id`.
This is useful for example when you want to send a single print job to a label printer for all the labels that are
printed within a context (e.g. a shipment).

Example:

```ruby
Papyrus.consolidate do
  Papyrus::Paper.new(kind: 'liquid', use: 'label', purpose: 'whatever', owner: User.first, attachment: {io: StringIO.new("^XA^BY5,2,270^FO100,50^BC^FD12345678^FS^XZ"), filename: 'test.zpl'}, consolidation_id: 'shipment-123').print!
  Papyrus::Paper.new(kind: 'liquid', use: 'label', purpose: 'whatever', owner: User.first, attachment: {io: StringIO.new("^XA^BY5,2,270^FO100,50^BC^FD12345678^FS^XZ"), filename: 'test.zpl'}, consolidation_id: 'shipment-123').print!

  # Paper 1 and 2 will be consolidated into a single print job and sent to the printer
  Papyrus.print_consolidation(Papyrus.consolidation_id)
end
```

If you have Sidekiq Pro `Papyrus::Consolidation::Batch` can be used to consolidate print jobs asynchronously.
In order to make use of this you need to add the following to your `config/initializers/sidekiq.rb` or in any other
initializer:

```ruby
require 'papyrus/consolidation/sidekiq_client_middleware'
require 'papyrus/consolidation/sidekiq_server_middleware'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Papyrus::Consolidation::SidekiqServerMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Papyrus::Consolidation::SidekiqClientMiddleware
  end
end
```

Example usage:

```ruby
require 'papyrus/consolidation/batch'

Papyrus::Consolidation::Batch.start do
  Job1.perform_async
  Job2.perform_async
end
```

When all jobs are finished a consolidated print job will start.
Any job that is executed within a job will be also added to the batch.

## PDF Generation

This is done using Prawn. See here for more info:

- [Prawn](https://prawnpdf.org/manual.pdf)
- [Prawn Tables](http://prawnpdf.org/prawn-table-manual.pdf)
- Barcodes are generated using barby: https://github.com/toretore/barby/wiki/Symbologies

## Installation

Papyrus depends on imagemagic for some operations

Add this line to your application's Gemfile:

```ruby
gem 'papyrus'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install papyrus
```

## Using linked frontend dependency

Run `yarn link` inside `frontend` folder
Run `yarn link @components/papyrus` inside your main app.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
