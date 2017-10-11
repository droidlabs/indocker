class Indocker::ImageMetadataRepository
  include SmartIoC::Iocify
  
  bean :image_metadata_repository

  def method_missing(method, *args)
    find_by_repo(method)
  rescue
    nil
  end

  def put(image_metadata)
    all.push(image_metadata)
  end

  def find_by_repo(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    image_metadata = all.detect { |im| im.repo == repo.intern and im.tag == tag.intern }
    raise Indocker::Errors::ImageIsNotDefined, "#{repo}:#{tag}" if image_metadata.nil?

    image_metadata
  end

  def clear
    @all = []
  end

  def all
    @all ||= []
  end
end