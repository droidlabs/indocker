class Indocker::ImageDirectives::Entrypoint < Indocker::ImageDirectives::Base
  attr_reader :command

  def initialize(command)
    @command = command
  end

  def to_dockerfile
    "#{type} #{command.inspect}"
  end
  
  def type
    'ENTRYPOINT'
  end

  def build_directive?
    true
  end
end