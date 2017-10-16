class Indocker::ContainerMetadataFactory
  include SmartIoC::Iocify

  bean   :container_metadata_factory
  inject :docker_api
  inject :container_evaluator
  inject :image_metadata_repository

  def create(name, &definition)
    context      = Indocker::DSLContext.new(
      images: image_metadata_repository
    )

    directives = container_evaluator.evaluate(context, &definition)

    Indocker::ContainerMetadata.new(
      name:         name.to_s,
      directives:   directives     
    )
  end
end