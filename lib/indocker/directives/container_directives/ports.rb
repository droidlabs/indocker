class Indocker::ContainerDirectives::Ports < Indocker::ContainerDirectives::Base
  attr_accessor :docker_port, :host_port

  def initialize(docker_port:, host_port:)
    @docker_port = docker_port
    @host_port   = host_port
  end
end