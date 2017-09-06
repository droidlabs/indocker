class Indocker::ImageBuildService 
  def build(image_name)
    image_name = image_name.to_s

    prepare_image(image_name)
    build_image(image_name)
  end

  private

  def prepare_image(image_name)
    before_build = get_image(image_name).prepare

    instance_eval &before_build
  end

  def build_image(image_name)
    image = get_image(image_name)

    build_dir = File.join(Indocker.build_dir('~/dev/indocker/spec/example'), image_name)
    FileUtils.mkdir_p(build_dir)

    File.open(File.join(build_dir, Indocker::DOCKERFILE_NAME), 'w') {|f| f.write image.to_dockerfile}
    
    FileUtils.cd(build_dir) do
      image.id = Indocker::DockerCommands.new.build_image(image_name)
    end
  end

  def get_image(image_name)
    image = Indocker.images.detect { |image| image.name == image_name }
    raise Indocker::Errors::ImageDoesNotDefined, image_name if image.nil?

    image
  end
end