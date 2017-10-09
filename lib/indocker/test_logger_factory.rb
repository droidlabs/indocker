class Indocker::TestLoggerFactory
  include SmartIoC::Iocify

  bean :logger, context: :test, factory_method: :build

  def build
    logger = Indocker::TestLogger.new

    logger.level = Logger::DEBUG
    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{severity}".colorize(:blue) +": (#{progname}): #{msg}\n"
    end

    logger
  end
end
