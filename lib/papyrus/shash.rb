# frozen_string_literal: true

class Shash < Hash
  def initialize(constructor = {})
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)

      hash              = constructor.to_hash
      self.default      = hash.default if hash.default
      self.default_proc = hash.default_proc if hash.default_proc
    else
      super(constructor)
    end
  end

  def self.[](*args)
    new.merge!(Hash[*args])
  end

  alias regular_reader [] unless method_defined?(:regular_reader)
  alias regular_writer []= unless method_defined?(:regular_writer)

  alias regular_default default
  def default(d = nil)
    @default = d if d
    key?('default') ? self['default'] : regular_default(d)
  end

  alias regular_keys keys
  def keys
    key?('keys') ? self['keys'] : regular_keys
  end

  def []=(key, value)
    regular_writer(convert_key(key), convert_value(value, for: :assignment))
  end

  alias store []=

  def [](key)
    super(convert_key(key))
  end

  def update(other_hash)
    if other_hash.is_a? Shash
      super(other_hash)
    else
      other_hash.to_hash.each_pair do |key, value|
        value = yield(convert_key(key), self[key], value) if block_given? && key?(key)
        regular_writer(convert_key(key), convert_value(value))
      end
      self
    end
  end

  alias merge! update

  def convert_value(v, _options = {})
    v = Shash.new(v) if v.is_a?(Hash)
    v = v.map { |item| item.is_a?(Hash) ? Shash.new(item) : item } if v.is_a?(Array)
    v
  end

  def method_missing(method_name, *args)
    if method_name[-1] == '='
      self[method_name] = args.first
    else
      self[method_name]
    end
  end

  def to_h
    result = {}
    each_pair do |key, value|
      result[key] = if value.is_a?(Shash)
                      value.to_h
                    elsif value.is_a?(Array)
                      value.map { |i| i.is_a?(Shash) ? i.to_h : i }
                    else
                      value
                    end
    end
    result
  end
  alias to_hash to_h

  def -(other)
    result = {}
    each_pair do |key, value|
      if other.key?(key.to_s)
        # puts "#{key} - #{value} == #{other[key]}"

        if value.is_a?(Shash)
          result[key] = (value - other[key]).to_h
        elsif value.is_a?(Array)
          # This needs some solution
          result[key] = value
        elsif value != other[key]
          result[key] = value
        end
      else
        result[key] = if value.is_a?(Shash)
                        value.to_h
                      else
                        value
                      end
      end
    end
    result
  end

  def fetch(key, fallback = nil)
    super(convert_key(key), fallback)
  end

  private

  # :doc:
  def convert_key(key)
    key.is_a?(Symbol) ? key.to_s : key
  end
end
