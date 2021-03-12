# Papyrus

Paper generation based on templates. Web-based printing using print-client.

## Usage

The context of the templates will using Liquid Drops, and call `to_liquid` on your objects.
In case you want web-printing, the params needs an owner and possibly a locale. Use `default_params` on the configuration object to get these or extract them from the transaction log (entry).

```ruby
config.default_params = lambda { |transaction_log_entry|
  { owner: transaction_log_entry.transaction_log.user, locale: I18n.locale }
}
```

Install the Print Client app: https://www.neodynamic.com/downloads/jspm/

## PDF Generation

This is done using Prawn. See here for more info:

- [Prawn](https://prawnpdf.org/manual.pdf)
- [Prawn Tables](http://prawnpdf.org/prawn-table-manual.pdf)
- Barcodes are generated using barby: https://github.com/toretore/barby/wiki/Symbologies

## Installation

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
