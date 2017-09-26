class Indocker::ImageBuildService 
  include SmartIoC::Iocify

  bean   :image_build_service
  inject :image_repository
  inject :image_dependencies_manager
  inject :container_runner_service
  inject :image_evaluator
  inject :docker_api

  def build(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    image_metadata = image_repository.find_by_repo(repo, tag: tag)

    image_definition = image_evaluator.evaluate(Indocker::ImageContext.new, &image_metadata.definition)

    image_dependencies_manager.get_image_dependencies!(image_metadata).each do |dependency| 
      build(dependency.repository, tag: dependency.tag)
    end

    commands_runner.run_all(image_definition.prepare_commands)
    
    FileUtils.mkdir_p(image_metadata.build_dir)
    
    File.open(File.join(image_metadata.build_dir, Indocker::DOCKERFILE_NAME), 'w') do |f| 
      f.puts image_definition.map(&:to_s)
    end
    
    image = docker_api.build_from_dir(image_metadata)
    image_metadata.id = docker_api.find_image_by_repo(image_metadata.repository, tag: image_metadata.tag).id

    FileUtils.rm_rf(image_metadata.build_dir)
  end
end