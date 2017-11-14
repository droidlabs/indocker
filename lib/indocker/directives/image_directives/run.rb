class Indocker::ImageDirectives::Run < Indocker::ImageDirectives::Base
  def type
    'RUN'
  end

  def initialize(command)
    @command = command.split("\n").map(&:strip).join(' ')
  end

  def to_s
    "#{type} \"#{@command}\""
  end

  def build_directive?
    true
  end
end