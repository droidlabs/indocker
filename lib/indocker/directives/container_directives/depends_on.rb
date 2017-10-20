class Indocker::ContainerDirectives::DependsOn < Indocker::ContainerDirectives::Base
  attr_accessor :container_name

  def initialize(container_name)
    @container_name = container_name
  end
end