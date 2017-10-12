class Indocker::Handlers::RunContainer < Indocker::Handlers::Base
  include SmartIoC::Iocify

  bean   :run_container_handler
  
  inject :container_manager
  inject :container_metadata_repository
  inject :image_builder
  inject :application_initializer
  inject :docker_api
  inject :logger

  def handle(name:)
    name = name.to_s

    container_metadata = container_metadata_repository.get_by_name(name)

    if docker_api.container_exists?(name)
      container_manager.stop(name)
      container_manager.delete(name)
    end
    
    image_builder.build(container_metadata.repo, tag: container_metadata.tag)
    
    container_manager.create(name)

    container_manager.start(name)
  end
end