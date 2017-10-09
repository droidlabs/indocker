module Indocker::Handlers
  class Base 
    include SmartIoC::Iocify

    bean   :base_handler

    inject :logger
  
    def perform(options)
      self.method(:handle).call(options)
    rescue Docker::Error::ClientError => e
      logger.error(e.message)
    end
  end
end