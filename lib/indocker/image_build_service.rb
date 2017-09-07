class Indocker::ImageBuildService 
  def build(image_name)
    image_name = image_name.to_s

    image_dependencies = Indocker::ImageDependenciesManager.new.get_image_dependencies!(image_name)
    image_dependencies.each {|image_name| build(image_name) }

    Indocker::ImagePrepareService.new.prepare(image_name)
    build_image(image_name)
  end

  private

  def build_image(image_name)
    image = Indocker::ImageRepository.new.get_image(image_name)

    build_dir = File.join(Indocker.build_dir('~/dev/indocker/spec/example'), image_name)
    FileUtils.mkdir_p(build_dir)

    File.open(File.join(build_dir, Indocker::DOCKERFILE_NAME), 'w') {|f| f.write image.to_dockerfile}
    
    FileUtils.cd(build_dir) do
      image.id = Indocker::DockerCommands.new.build_image(image_name)
    end
  end
end