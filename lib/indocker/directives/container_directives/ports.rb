class Indocker::ContainerDirectives::Ports < Indocker::ContainerDirectives::Base
  attr_accessor :container_port, :host_port

  def initialize(container_port:, host_port:)
    @container_port = container_port
    @host_port      = host_port
  end

  def to_hash
    {
      container_port: @container_port,
      host_port:      @host_port
    }
  end
end