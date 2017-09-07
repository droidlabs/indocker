class Indocker::ImagePrepareService
  def prepare(image_name)
    image = Indocker::ImageRepository.new.get_image(image_name)

    before_build = image.before_build_block
    instance_eval &before_build
  end

  private

  def run_container(container_name)
    Indocker::ContainerRunnerService.new.run(container_name)
  end
end