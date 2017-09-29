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
      container_runner_service.create(name)
    rescue Docker::Error::NotFoundError
      container_metadata = container_repository.get_container(name)
      image_build_service.build(container_metadata.from_repo)
    end
  end
end