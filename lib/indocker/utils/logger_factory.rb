class Indocker::LoggerFactory
  include SmartIoC::Iocify

  bean :logger, factory_method: :build

  def build
    Indocker::Logger.new(STDOUT)
  end
end



