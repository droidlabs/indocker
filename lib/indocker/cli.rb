require 'thor'

class Indocker::CLI < Thor
  desc "run_container CONTAINER_NAME", "runs specified container"
  def run_container(name)
    ioc.application_initializer.init_app
    ioc.run_container_handler.handle(name)
  end
end