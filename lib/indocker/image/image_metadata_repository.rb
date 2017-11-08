class Indocker::ImageMetadataRepository
  include SmartIoC::Iocify
  include Indocker::ImageHelper
  
  bean :image_metadata_repository

  def put(image_metadata)
    all.push(image_metadata)
  end

  def find_by_full_name(image_metadata_full_name)
    image_metadata = all.detect { |image_metadata| image_metadata.full_name == image_metadata_full_name }
    raise Indocker::Errors::ImageIsNotDefined, image_metadata_full_name if image_metadata.nil?

    image_metadata
  end

  def find_by_repo(repo, tag: nil)
    find_by_full_name(full_name(repo, tag))
  end

  def clear
    @all = []
  end

  def all
    @all ||= []
  end
end