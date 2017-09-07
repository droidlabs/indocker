class Indocker::ImageDependenciesManager
  def get_image_dependencies(image_name)
    image = get_image(image_name)
    @container_dependencies = []

    before_build = image.before_build_block
    instance_exec &before_build

    @container_dependencies.map {|container_name| get_container(container_name).from }
  end

  private
  
  def run_container(container_name)
    @image_dependencies.push container_name
  end

  def get_container(container_name)
    container = Indocker.containers.detect {|container| container.name == container_name}
    raise Indocker::Errors::ContainerDoesNotDefined if container.nil?

    container
  end
end