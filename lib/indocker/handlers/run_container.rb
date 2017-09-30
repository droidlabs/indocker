module Indocker::Handlers
  class RunContainer
    include SmartIoC::Iocify

    bean   :run_container_handler
    inject :container_runner_service
    inject :container_repository
    inject :image_build_service
    inject :application_initializer

    def handle(name)
      application_initializer.init_app
      container = container_runner_service.create(name)
      container.start
    rescue Docker::Error::NotFoundError
      container_metadata = container_repository.get_container(name)
      image_build_service.build(container_metadata.repo)
      container_runner_service.create(name)
    ensure
      container = docker_api.get_container(name)
      container.stop
      container.delete
    end
  end
end