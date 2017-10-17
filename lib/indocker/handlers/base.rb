module Indocker::Handlers
  class Base 
    def perform(options)
      env = options.delete(:env)

      application_initializer.init_app(options[:current_path], env: env)

      self.method(:handle).call(options)
    rescue Docker::Error::ClientError => e
      logger.error(e.message)
    end
  end
end