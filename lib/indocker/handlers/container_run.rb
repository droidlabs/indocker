class Indocker::Handlers::ContainerRun
  include SmartIoC::Iocify

  bean   :run_container_handler
  
  inject :container_manager
  inject :container_metadata_repository
  inject :image_builder

  include Indocker::Handlers::Performable

  def handle(name:, current_path:)
    name = name.to_s

    container_metadata = container_metadata_repository.find_by_name(name)
    image_builder.build(container_metadata.repo, tag: container_metadata.tag)
    
    container_manager.run(name)
  end
end