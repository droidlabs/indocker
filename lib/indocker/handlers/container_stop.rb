class Indocker::Handlers::ContainerStop
  include SmartIoC::Iocify
  
  bean   :stop_container_handler

  inject :container_manager
  inject :container_metadata_repository
  inject :image_builder

  include Indocker::Handlers::Performable

  def handle(name:, current_path:)
    name = name.to_s

    container_manager.stop(name)
  end
end