class Indocker::ContainerDirectives::Volume < Indocker::ContainerDirectives::Base
  attr_accessor :volume_name, :to

  def initialize(volume_name:, to:)
    @volume_name = volume_name
    @to          = to
  end

  def before_start?
    true
  end
end