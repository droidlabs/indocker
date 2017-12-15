class Indocker::ImageBuilder
  include SmartIoC::Iocify

  bean   :image_builder
  
  inject :image_metadata_repository
  inject :image_dependencies_manager
  inject :image_directives_runner
  inject :docker_api
  inject :logger
  inject :image_dockerfile_builder
  inject :file_utils
  inject :config

  def build(repo, tag: Indocker::ImageHelper::DEFAULT_TAG)
    image_metadata = image_metadata_repository.find_by_repo(repo, tag: tag)

    return if image_metadata.already_built?

    file_utils.within_temporary_directory(image_metadata.build_dir) do
      image_dependencies_manager.get_dependencies!(image_metadata).each do |dependency_metadata| 
        build(dependency_metadata.repo, tag: dependency_metadata.tag)
      end

      image_directives_runner.run_all(image_metadata.prepare_directives)

      File.open(File.join(image_metadata.build_dir, Indocker::DOCKERFILE_NAME), 'w') do |f| 
        f.puts image_dockerfile_builder.build(*image_metadata.build_directives)

        logger.debug image_dockerfile_builder.build(*image_metadata.build_directives)
      end

      file_utils.cp_r_with_modify(
        from: config.template_dir.join('.dockerignore'), 
        to:   image_metadata.build_dir
      )

      logger.info("Start build #{repo}:#{tag}")

      image_metadata.id = docker_api.build_from_dir(
        repo:      image_metadata.repo,
        tag:       image_metadata.tag,
        build_dir: image_metadata.build_dir.to_s
      ) { |log| logger.info(log) }

      image_directives_runner.run_all(image_metadata.after_build_directives)
    end
  end
end