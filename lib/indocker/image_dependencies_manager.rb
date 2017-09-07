class Indocker::ImageDependenciesManager
  def get_image_dependencies!(image_name)
    check_circular_dependencies!(image_name)

    get_image_dependencies(image_name)
  end

  private

  def check_circular_dependencies!(image_name, used_images = [])
    raise Indocker::Errors::CircularImageDependency if used_images.include?(image_name)

    used_images.push(image_name)

    get_image_dependencies(image_name).each do |dep_name|
      check_circular_dependencies!(dep_name, used_images)
    end

    nil
  end

  def get_image_dependencies(image_name)
    image = Indocker::ImageRepository.new.get_image(image_name)
    @container_dependencies = []

    before_build = image.before_build_block
    instance_exec &before_build

    @container_dependencies.map {|container_name| Indocker::ContainerRepository.new.get_container(container_name).from }
  end
  
  def run_container(container_name)
    @container_dependencies.push container_name
  end
end