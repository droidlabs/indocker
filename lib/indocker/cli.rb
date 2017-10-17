require 'thor'

module Indocker
  module CLI
    class Application < Thor
      desc   "container:run CONTAINER_NAME", "runs specified container"
      option :env
      define_method('container:run') do |name, env = :development|
        ioc.run_container_handler.perform(
          name:         name,
          current_path: Dir.pwd,
          env:          env
        )
      end
    end
  end
end