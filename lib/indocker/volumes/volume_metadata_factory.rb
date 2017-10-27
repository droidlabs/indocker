class Indocker::Volumes::VolumeMetadataFactory
  include SmartIoC::Iocify

  bean :volume_metadata_factory

  def create(name)
    Indocker::Volumes::VolumeMetadata.new(name.to_s)
  end
end