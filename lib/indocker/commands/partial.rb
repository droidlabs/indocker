class Indocker::Commands::Partial
  attr_reader :name, :context

  def initialize(name, context, opts = {})
    @name    = name
    @context = context
    @opts    = opts
  end
end