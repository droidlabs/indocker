class Indocker::DockerDirectives::Run < Indocker::DockerDirectives::Base
  def type
    'RUN'
  end

  def initialize(command)
    @command = command.split("\n").map(&:strip).join(' ')
  end

  def to_s
    "#{type} #{@command}"
  end
end