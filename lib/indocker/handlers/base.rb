module Indocker::Handlers
  class Base 
    def perform(options)
      application_initializer.init_app

      self.method(:handle).call(options)
    rescue Docker::Error::ClientError => e
      logger.error(e.message)
    end
  end
end