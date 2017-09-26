class Indocker::BeforeBuildDSL
  attr_reader :containers

  def initialize(context)
    @context = context
  end

  def method_missing(method, *args)
    @context.send(method)
  rescue
    super
  end

  def set_arg(key, value)
    @context.set_value(key, value)
  end
end