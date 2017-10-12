class Indocker::ImageMetadataFactory
  include SmartIoC::Iocify

  bean   :image_metadata_factory
  
  inject :image_evaluator
  inject :docker_api

  def create(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG, &definition)
    context    = Indocker::DSLContext.new( { build_dir: build_dir(repo) } )
    directives = image_evaluator.evaluate(context, &definition)

    Indocker::ImageMetadata.new(
      repo:       repo.intern,
      tag:        tag.intern,
      directives: directives,
      build_dir:  build_dir(repo)
    )
  end

  private

  def build_dir(name)
    File.join(Indocker.root, Indocker::BUILD_DIR, name.to_s)
  end
end