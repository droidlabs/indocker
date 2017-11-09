class Indocker::ContainerDirectives::EnvFile < Indocker::DockerDirectives::Base
  attr_reader :path
  
  def initialize(path)
    @path = path
  end
end