class Indocker::ContainerDirectives::EnvFile < Indocker::ImageDirectives::Base
  attr_reader :path
  
  def initialize(path)
    @path = path
  end
end