class Indocker::ContainerDirectives::Network < Indocker::ContainerDirectives::Base
  attr_accessor :network_name, :container_name

  def initialize(network_name:, container_name:)
    @network_name   = network_name
    @container_name = container_name
  end

  def before_start?
    true
  end
end