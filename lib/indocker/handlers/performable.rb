module Indocker
  module Handlers
    module Performable
      def self.included(klass)
        klass.inject(:logger)
        klass.inject(:application_initializer)
      end

      def perform(options)
        env = options.delete(:env)

        application_initializer.init_app(options[:current_path], env: env)

        self.method(:handle).call(options)
      rescue Docker::Error::ClientError => e
        logger.error e.message
      rescue Docker::Error::NotFoundError => e
        logger.error(e.message)
      end
    end
  end
end