class Indocker::ImageBuildService 
  include SmartIoC::Iocify

  bean   :image_build_service
  inject :image_repository
  inject :image_dependencies_manager
  inject :image_prepare_service
  inject :docker_api

  def build(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    image_metadata = image_repository.find_by_repo(repo, tag: tag)

    image_dependencies = image_dependencies_manager.get_image_dependencies!(image_metadata)
    image_dependencies.each {|dependency| build(dependency.repository, tag: dependency.tag) }

    image_prepare_service.prepare(image_metadata)
    build_image(image_metadata)
  end

  private

  def build_image(image_metadata)
    image = docker_api.find_image_by_repo(image_metadata.repository, tag: image_metadata.tag)

    FileUtils.mkdir_p(image_metadata.build_dir)

    File.open(File.join(image_metadata.build_dir, Indocker::DOCKERFILE_NAME), 'w') do |f| 
      f.write image_metadata.to_dockerfile
    end
    
    image = docker_api.build_from_dir(image_metadata)
    image_metadata.id = docker_api.find_image_by_repo(image_metadata.repository, tag: image_metadata.tag).id

    FileUtils.rm_rf(image_metadata.build_dir)
  end
end