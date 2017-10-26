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

      desc   "container:stop CONTAINER_NAME", "stops specified container"
      option :env
      define_method('container:stop') do |name, env = :development|
        ioc.stop_container_handler.perform(
          name:         name,
          current_path: Dir.pwd,
          env:          env
        )
      end
    end
  end
end