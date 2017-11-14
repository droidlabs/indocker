class Indocker::DSLContext
  attr_reader :storage

  def initialize(storage = {})
    @storage = storage
  end

  def method_missing(method, *args)
    super unless @storage.key?(method)

    @storage.fetch(method)
  end

  def set_value(key, value)
    @storage[key] = value
  end

  def +(other)
    Indocker::DSLContext.new(@storage.merge(other.storage))
  end
end