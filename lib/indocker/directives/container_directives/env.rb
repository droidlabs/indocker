class Indocker::ContainerDirectives::Env < Indocker::ContainerDirectives::Base
  attr_reader :env_string
  
  def initialize(env_string)
    @env_string = env_string.split(' ')
  end
end