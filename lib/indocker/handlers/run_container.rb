class Indocker::Handlers::RunContainer < Indocker::Handlers::Base
  bean   :run_container_handler
  
  inject :container_runner
  inject :container_metadata_repository
  inject :image_builder
  inject :application_initializer
  inject :docker_api
  inject :logger

  def handle(name:, rebuild: false)
    application_initializer.init_app

    container_metadata = container_metadata_repository.get_container(name)
    container          = docker_api.find_container_by_name(name)

    if (container.nil? || rebuild)
      container.delete(force: true) if container

      image_builder.build(container_metadata.repo, tag: container_metadata.tag)

      container = container_runner.create(name)
    else
      container.stop
    end

    

    if container.start.wait(10)["StatusCode"] == 1
      logger.error container.logs(:stdout => true)
    else
      logger.info "Successfully started container #{name}"
    end
  end
end