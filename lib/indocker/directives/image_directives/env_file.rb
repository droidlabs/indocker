class Indocker::ImageDirectives::EnvFile < Indocker::ImageDirectives::Base
  attr_reader :path
  
  def initialize(path)
    @path = path
  end

  def type
    'ENV'
  end
  
  def to_dockerfile(env_string)
    "#{type} #{env_string}"
  end

  def build_directive?
    true
  end
end