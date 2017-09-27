class Indocker::ImageDependenciesManager
  include SmartIoC::Iocify

  bean   :image_dependencies_manager
  inject :image_repository
  inject :container_repository
  inject :image_evaluator

  def get_image_dependencies!(image_metadata)
    check_circular_dependencies!(image_metadata)

    get_image_dependencies(image_metadata)
  end

  private

  def check_circular_dependencies!(image_metadata, used_images = [])
    raise Indocker::Errors::CircularImageDependency if used_images.include?(image_metadata.full_name)

    used_images.push(image_metadata.full_name)

    get_image_dependencies(image_metadata).each do |dependency|
      check_circular_dependencies!(dependency, used_images)
    end

    nil
  end

  def get_image_dependencies(image_metadata)
    image_evaluator.evaluate(&image_metadata.definition)
      .select {|c| c.instance_of?(Indocker::PrepareCommands::DockerCp)}  
      .map do |c| 
        container = container_repository.get_container(c.container_name)

        image_repository.find_by_repo(container.from_repo, tag: container.from_tag)
      end
  end
end