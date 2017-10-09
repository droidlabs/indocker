require 'thor'

module Indocker
  module CLI
    class Application < Thor
      desc          "container:run CONTAINER_NAME", "runs specified container"
      method_option :rebuild, type: :boolean, aliases: '-r'
      define_method('container:run') do |name|
        ioc.run_container_handler.perform(
          name:    name,
          rebuild: options[:rebuild]
        )
      end
    end
  end
end