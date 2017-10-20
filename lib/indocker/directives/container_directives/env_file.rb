class Indocker::ContainerDirectives::EnvFile < Indocker::ContainerDirectives::Base
  attr_accessor :path

  def initialize(path)
    @path = path
  end
end