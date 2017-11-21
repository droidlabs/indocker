class Indocker::ContainerDirectives::EnvFile < Indocker::ContainerDirectives::Base
  attr_reader :path
  
  def initialize(path)
    @path = path
  end
end