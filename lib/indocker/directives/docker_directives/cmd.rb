class Indocker::DockerDirectives::Cmd < Indocker::DockerDirectives::Base
  attr_reader :command

  def initialize(command)
    @command = command
  end

  def to_s
    "#{type} #{command.inspect}"
  end

  def type
    'CMD'
  end
end