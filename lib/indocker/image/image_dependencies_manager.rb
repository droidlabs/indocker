class Indocker::ImageDependenciesManager
  include SmartIoC::Iocify

  bean   :image_dependencies_manager
  inject :image_repository
  inject :container_repository
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

  def get_dependencies(image_metadata)
    container_dependencies = image_metadata.prepare_commands.map do |c|
      container = container_repository.get_container(c.container_name)
      
      image_repository.find_by_repo(container.from_repo, tag: container.from_tag)
    end
    
    return container_dependencies if image_metadata.dockerhub_image?
    
    from_image_dependency = image_repository.find_by_repo(image_metadata.from_repo, tag: image_metadata.from_tag)

    container_dependencies.push from_image_dependency
  end
end