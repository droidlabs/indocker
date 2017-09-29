class Indocker::Directives::Partial < Indocker::Directives::Base
  attr_reader :name, :context

  def initialize(name, context, opts = {})
    @name    = name
    @context = context
    @opts    = opts
  end

  def to_s
    inspect
  end
end