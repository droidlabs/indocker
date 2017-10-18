class Indocker::Networks::NetworkMetadataFactory
  include SmartIoC::Iocify

  bean :network_metadata_factory

  def create(name)
    Indocker::Networks::NetworkMetadata.new(name.to_s)
  end
end