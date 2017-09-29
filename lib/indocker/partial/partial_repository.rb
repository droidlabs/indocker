class PartialRepository
  include SmartIoC::Iocify
  
  bean :partial_repository

  def find_by_name(name)
    partial = all.detect do |p| 
      p.name == name
    end
    raise Indocker::Errors::PartialIsNotDefined, name if partial.nil?

    partial
  end

  def all
    Indocker.partials
  end
end