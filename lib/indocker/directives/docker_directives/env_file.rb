class Indocker::DockerDirectives::EnvFile < Indocker::DockerDirectives::Base
  attr_reader :path
  
  def initialize(path)
    @path = path
  end

  def type
    'ENV'
  end
  
  def to_s(env_string)
    "#{type} #{env_string}"
  end
end