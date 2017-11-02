class Indocker::Volumes::VolumeMetadataRepository
  include SmartIoC::Iocify

  bean :volume_metadata_repository
  
  def put(volume_metadata)
    if all.any? {|n| n.name == volume_metadata.name}
      raise Indocker::Errors::VolumeAlreadyDefined, volume_metadata.name 
    end

    all.push(volume_metadata)
  end

  def find_by_name(name)
    volume_metadata = @all.detect {|volume| volume.name == name.to_s}
    raise Indocker::Errors::VolumeIsNotDefined unless volume_metadata

    volume_metadata
  end

  def clear
    @all = []
  end

  def all
    @all ||= []
  end

  def method_missing(method)
    find_by_name(method)
  rescue 
    super
  end
end