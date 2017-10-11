class Indocker::TestLoggerFactory
  include SmartIoC::Iocify

  bean :logger, context: :test, factory_method: :build

  def build
    Indocker::TestLogger.new
  end
end
