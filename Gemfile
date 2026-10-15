source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in papyrus.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

git_source(:entdec) { |repo| "git@github.com:entdec/#{repo}.git" }
gem "mensa", entdec: "mensa"

# Mensa's current install migrations use Rails 8.1.
gem "rails", "~> 8.1.0"
