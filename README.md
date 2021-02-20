# Papyrus

Paper generation based on templates. Web-based printing using print-client.

## Usage

The context of the templates will be a serialized version of your record, papyrus will call `to_papyrus` on your objects. If that doesn't exist, it will call as_json.
In case you want web-printing, the options needs an owner, so you could make your `ApplicationGenerator` something like this:

```ruby
# frozen_string_literal: true

class ApplicationGenerator < Papyrus::Generator
  set_callback :action, :before, :set_current_objects

  private

  def set_current_objects
    @options.merge!(owner: Current.user, locale: I18n.locale)
  end
end
```

Install the Print Client app: https://www.neodynamic.com/downloads/jspm/

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
