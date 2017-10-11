class Indocker::ContainerMetadataRepository
  include SmartIoC::Iocify

  bean   :container_metadata_factory
  inject :docker_api
  inject :container_evaluator
  inject :image_metadata_repository

  def create(name, &definition)
    context      = Indocker::DSLContext.new(
      images: image_metadata_repository
    )
    container_id = docker_api.find_container_by_name(name)
    directives   = container_evaluator.evaluate(context, &definition)
    
    Indocker::ContainerMetadata.new(
      name:         name.intern,
      directives:   directives,         
      container_id: container_id
    )
  end
end