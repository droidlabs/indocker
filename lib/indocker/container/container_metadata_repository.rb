class Indocker::ContainerRepository
  include SmartIoC::Iocify
  
  bean :container_metadata_repository

  def put(container_metadata)
    all.push(container_metadata)
  end

  def get_container(container_name)
    container = all.detect {|container| container.name == container_name.to_sym}
    raise Indocker::Errors::ContainerIsNotDefined if container.nil?

    container
  end

  def clear
    @all = []
  end

  def all
    @all ||= []
  end
end