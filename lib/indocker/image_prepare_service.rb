class Indocker::ImagePrepareService
  include SmartIoC::Iocify
  
  bean   :image_prepare_service
  inject :image_repository
  inject :container_runner_service

  def prepare(image_metadata)
    before_build = image_metadata.before_build_block
    instance_eval &before_build
  end

  private

  def run_container(container_name)
    container_runner_service.run(container_name)
  end
end