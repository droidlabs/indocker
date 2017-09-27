class Indocker::ImageBuildService 
  include SmartIoC::Iocify

  bean   :image_build_service
  inject :image_repository
  inject :image_dependencies_manager
  inject :commands_runner
  inject :image_evaluator
  inject :docker_api

  def build(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    image_metadata = image_repository.find_by_repo(repo, tag: tag)
    FileUtils.mkdir_p(image_metadata.build_dir)

    context  = Indocker::ImageContext.new(build_dir: image_metadata.build_dir)
    commands = image_evaluator.evaluate(context, &image_metadata.definition)

    image_dependencies_manager.get_image_dependencies!(image_metadata).each do |dependency| 
      build(dependency.repository, tag: dependency.tag)
    end

    commands_runner.run_all(
      commands.select {|c| c.instance_of?(Indocker::PrepareCommands::DockerCp)}
    )

    File.open(File.join(image_metadata.build_dir, Indocker::DOCKERFILE_NAME), 'w') do |f| 
      f.puts commands.reject {|c| c.instance_of?(Indocker::PrepareCommands::DockerCp)}.map(&:to_s)
    end

    image = docker_api.build_from_dir(image_metadata)
    image_metadata.id = docker_api.find_image_by_repo(image_metadata.repository, tag: image_metadata.tag).id

    FileUtils.rm_rf(image_metadata.build_dir)
  end
end