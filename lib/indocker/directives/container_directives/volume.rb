class Indocker::ContainerDirectives::Volume < Indocker::ContainerDirectives::Base
  attr_accessor :volume_name, 

  def initialize(volume_name:)
    @volume_name   = volume_name
  end

  def before_start?
    true
  end
end