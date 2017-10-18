class Indocker::ImageBuilder
  include SmartIoC::Iocify

  bean   :image_builder
  
  inject :image_metadata_repository
  inject :image_dependencies_manager
  inject :image_directives_runner
  inject :image_evaluator
  inject :docker_api
  inject :logger

  def build(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    image_metadata = image_metadata_repository.find_by_repo(repo, tag: tag)
    
    FileUtils.mkdir_p(image_metadata.build_dir)
    
    image_dependencies_manager.get_dependencies!(image_metadata).each do |dependency_metadata| 
      build(dependency_metadata.repo, tag: dependency_metadata.tag)
    end
    
    image_directives_runner.run_all(image_metadata.prepare_directives)

    File.open(File.join(image_metadata.build_dir, Indocker::DOCKERFILE_NAME), 'w') do |f| 
      f.puts       image_metadata.build_directives.map(&:to_s)
      image_metadata.build_directives.map(&:to_s).each {|d| logger.debug d}
    end

    docker_api.build_from_dir(
      repo:      image_metadata.repo,
      tag:       image_metadata.tag,
      build_dir: image_metadata.build_dir.to_s
    ) { |log| logger.info(log) }
  ensure
    image_metadata = image_metadata_repository.find_by_repo(repo, tag: tag)

    FileUtils.rm_rf(image_metadata.build_dir)
  end
end