class Indocker::Directives::Partial < Indocker::Directives::Base
  attr_reader :name

  def initialize(name, context, opts = {})
    @name    = name
    @context = context
    @opts    = opts
  end

  def to_s
    inspect
  end

  def context
    @context + Indocker::DSLContext.new(@opts)
  end

  def partial_directive?
    true
  end
end