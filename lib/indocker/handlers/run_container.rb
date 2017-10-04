module Indocker::Handlers
  class RunContainer
    include SmartIoC::Iocify

    bean   :run_container_handler
    
    inject :container_runner
    inject :container_metadata_repository
    inject :image_builder
    inject :application_initializer
    inject :docker_api

    def handle(name)
      application_initializer.init_app

      container_metadata = container_metadata_repository.get_container(name)
      container          = docker_api.find_container_by_name(name) || 
                           container_runner.create(name)

      container.start
    end
  end
end