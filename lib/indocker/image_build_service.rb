class Indocker::ImageBuildService 
  include SmartIoC::Iocify

  bean   :image_build_service
  inject :image_repository
  inject :image_dependencies_manager
  inject :docker_commands
  inject :image_prepare_service

  def build(image_name)
    image_name = image_name.to_s

    image_dependencies = image_dependencies_manager.get_image_dependencies!(image_name)
    image_dependencies.each {|image_name| build(image_name) }

    image_prepare_service.prepare(image_name)
    build_image(image_name)
  end

  private

  def build_image(image_name)
    image = image_repository.get_image(image_name)

    build_dir = File.join(Indocker.build_dir('~/dev/indocker/spec/example'), image_name)
    FileUtils.mkdir_p(build_dir)

    File.open(File.join(build_dir, Indocker::DOCKERFILE_NAME), 'w') {|f| f.write image.to_dockerfile}
    
    FileUtils.cd(build_dir) do
      image.id = docker_commands.build_image(image_name)
    end
  end
end