class Indocker::ContainerDirectives::Expose < Indocker::ContainerDirectives::Base
  attr_accessor :port

  def initialize(port)
    @port = port
  end
end