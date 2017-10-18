class Indocker::Networks::NetworkMetadataRepository
  include SmartIoC::Iocify

  bean :network_metadata_repository
  
  def put(network_metadata)
    if all.any? {|n| n.name == network_metadata.name}
      raise Indocker::Errors::NetworkAlreadyDefined, network_metadata.name 
    end

    all.push(network_metadata)
  end

  def find_by_name(name)
    network_metadata = @all.detect {|network| network.name == name.to_s}
    raise Indocker::Errors::NetworkIsNotDefined unless network_metadata

    network_metadata
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