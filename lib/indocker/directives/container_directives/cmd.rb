class Indocker::ContainerDirectives::Cmd < Indocker::ContainerDirectives::Base
  attr_accessor :container_name

  def initialize(command)
    @command = command
  end
end