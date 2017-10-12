class Indocker::ContainerMetadataRepository
  include SmartIoC::Iocify
  
  bean :container_metadata_repository

  def put(metadata)
    if get_by_name(metadata.name)
      raise Indocker::Errors::InvalidParams, "Container name '#{metadata.name}' already in use"
    end
    
    all.push(metadata)
  end

  def get_by_name(container_name)
    container = all.detect {|container| container.name == container_name.to_s}

    container
  end

  def clear
    @all = []
  end

  def all
    @all ||= []
  end
end