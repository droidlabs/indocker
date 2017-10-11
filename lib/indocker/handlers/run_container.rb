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

    name = name.intern

    container_metadata = container_metadata_repository.get_container(name)
    container          = docker_api.find_container_by_name(name)

    if (container.nil? || rebuild)
      container.delete(force: true) if container

      image_builder.build(container_metadata.repo, tag: container_metadata.tag)

      container = container_runner.create(name)
    else
      container.stop
    end

    container.start! && sleep(1)
    
    if container.refresh!.info["State"]["Running"]
      logger.info "Successfully started container :#{name}"
    else
      logger.error container.logs(:stdout => true)
    end

    container.id
  end
end