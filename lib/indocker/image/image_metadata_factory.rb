class Indocker::ImageMetadataFactory
  include SmartIoC::Iocify

  bean   :image_metadata_factory
  inject :image_evaluator
  inject :docker_api

  def create(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG, &definition)
    context  = Indocker::ImageContext.new( { build_dir: build_dir(repo) } )
    commands = image_evaluator.evaluate(context, &definition)
    image_id = docker_api.find_image_by_repo(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)

    Indocker::ImageMetadata.new(
      repo:      repo,
      tag:       tag,
      commands:  commands,
      build_dir: build_dir(repo),
      image_id:  image_id
    )
  end

  private

  def build_dir(name)
    File.join(Indocker.root, Indocker::BUILD_DIR, name)
  end
end