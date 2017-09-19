class Indocker::LoggerFactory
  include SmartIoC::Iocify

  bean :logger, factory_method: :build

  def build
    Logger.new(STDOUT)
  end
end