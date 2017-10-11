class Indocker::PartialMetadataRepository
  include SmartIoC::Iocify
  
  bean :partial_metadata_repository

  def put(partial_metadata)
    all.push(partial_metadata)
  end

  def find_by_name(name)
    partial = all.detect do |p| 
      p.name == name
    end
    raise Indocker::Errors::PartialIsNotDefined, name if partial.nil?

    partial
  end

  def clear
    @all = []
  end

  def all
    @all ||= []
  end
end