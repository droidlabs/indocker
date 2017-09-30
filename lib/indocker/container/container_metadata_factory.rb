class Indocker::ContainerMetadataRepository
  include SmartIoC::Iocify

  bean   :container_metadata_factory
  inject :docker_api

  def create(name, repo:, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    container_id = docker_api.find_container_by_name(name)
    
    Indocker::ContainerMetadata.new(
      name:         name,
      repo:         repo,
      tag:          tag,         
      container_id: container_id
    )
  end
end