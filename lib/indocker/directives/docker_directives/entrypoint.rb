class Indocker::DockerDirectives::Entrypoint < Indocker::DockerDirectives::Base
  attr_reader :command

  def initialize(command)
    @command = command
  end

  def to_s
    "#{type} #{command.inspect}"
  end
  
  def type
    'ENTRYPOINT'
  end
end