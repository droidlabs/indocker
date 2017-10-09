require 'logger'
require 'colorize'

class Indocker::Logger < Logger
  def initialize(*)
    super
    @formatter = IndockerLoggerFormatter.new
  end
end


class Indocker::TestLogger < Indocker::Logger
  def initialize
    @strio = StringIO.new
    super(@strio)
  end

  def messages
    @strio.string.split("\n")
  end
end

class IndockerLoggerFormatter
  DEBUG = 'DEBUG'
  ERROR = 'ERROR'
  FATAL = 'FATAL'
  WARN  = 'WARN'
  INFO  = 'INFO'
  
  def call(severity, datetime, progname, msg)
    "#{colorize_log_level(severity)}: #{msg}\n"
  end

  private

  def colorize_log_level(severity)
    case severity
    when DEBUG
      severity.colorize(:grey)
    when ERROR
      severity.colorize(:red)
    when FATAL
      severity.colorize(:dark_red)
    when WARN
      severity.colorize(:white)
    when INFO
      severity.colorize(:green)
    else
      severity.colorize(:white)
    end
  end
end