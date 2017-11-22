class Indocker::ImageDependenciesManager
  include SmartIoC::Iocify

  bean   :image_dependencies_manager

  inject :repository, ref: :image_metadata_repository
  inject :container_metadata_repository
  inject :image_evaluator

  def get_dependencies!(image_metadata)
    check_circular_dependencies!(image_metadata)

    get_dependencies(image_metadata)
  end

  private

  def check_circular_dependencies!(image_metadata, used_images = [])
    raise Indocker::Errors::CircularImageDependency if used_images.include?(image_metadata.full_name)

    used_images.push(image_metadata.full_name)

    get_dependencies(image_metadata).each do |dependency|
      check_circular_dependencies!(dependency, used_images)
    end

    nil
  end

  def get_dependencies(meta)
    dependencies = []

    docker_cp_dependencies = meta.docker_cp_directives.map do |c|
      container = container_metadata_repository.find_by_name(c.container_name)
      
      repository.find_by_repo(container.repo, tag: container.tag)
    end

    dependencies.concat(docker_cp_dependencies)

    if !meta.dockerhub_image?
      dependencies << repository.find_by_repo(meta.from_repo, tag: meta.from_tag)
    end

    dependencies.uniq
  end
end