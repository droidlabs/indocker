class Indocker::Volumes::VolumeMetadataFactory
  include SmartIoC::Iocify

  bean :volume_metadata_factory

  def create(name:, source:, target:)
    Indocker::Volumes::VolumeMetadata.new(
      name:   name.to_s,
      source: source,
      target: target
    )
  end
end