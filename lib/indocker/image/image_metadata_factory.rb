class Indocker::ImageMetadataFactory
  include Indocker::ImageHelper
  include SmartIoC::Iocify

  bean   :image_metadata_factory
  
  inject :image_evaluator
  inject :docker_api
  inject :config
  inject :git_helper
  inject :registry_service

  def create(repo, tag: Indocker::ImageHelper::DEFAULT_TAG, &definition)
    context = Indocker::DSLContext.new(
      build_dir:  config.build_dir.join(repo.to_s),
      git:        git_helper,
      repo:       repo,
      tag:        tag,
      registry:   registry_service
    )
    
    directives = image_evaluator.evaluate(context, &definition)

    Indocker::ImageMetadata.new(
      repo:       repo.intern,
      tag:        tag.intern,
      directives: directives,
      build_dir:  config.build_dir.join(repo.to_s)
    )
  end
end