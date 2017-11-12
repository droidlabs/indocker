class Indocker::ImageDirectives::Cmd < Indocker::ImageDirectives::Base
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

  def build_directive?
    true
  end
end