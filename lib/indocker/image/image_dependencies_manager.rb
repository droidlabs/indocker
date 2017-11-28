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

  def check_circular_dependencies!(root_metadata, checked_metadata = nil)
    raise Indocker::Errors::CircularImageDependency if root_metadata == checked_metadata
    
    current_metadata = checked_metadata || root_metadata

    get_dependencies(current_metadata).each do |dependency|
      check_circular_dependencies!(root_metadata, dependency)
    end

    nil
  end

  def get_dependencies(meta)
    dependencies = []

    docker_cp_dependencies = meta.docker_cp_directives.map do |container|
      container_metadata = container_metadata_repository.find_by_name(container.container_name)
      
      repository.find_by_repo(container_metadata.repo, tag: container_metadata.tag)
    end

    dependencies.concat(docker_cp_dependencies)

    if !meta.dockerhub_image?
      dependencies << repository.find_by_repo(meta.from_repo, tag: meta.from_tag)
    end

    dependencies.uniq
  end
end