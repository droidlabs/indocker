class Indocker::ContainerDirectives::Cmd < Indocker::ContainerDirectives::Base
  attr_accessor :cmd

  def initialize(cmd)
    @cmd = cmd
  end
end