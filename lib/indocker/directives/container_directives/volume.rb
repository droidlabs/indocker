class Indocker::ContainerDirectives::Volume < Indocker::ContainerDirectives::Base
  attr_accessor :name, :to

  def initialize(name:, to:)
    @name = name
    @to   = to
  end

  def before_start?
    true
  end
end