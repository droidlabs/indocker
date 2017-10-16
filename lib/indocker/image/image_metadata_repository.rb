class Indocker::ImageMetadataRepository
  include SmartIoC::Iocify
  
  bean :image_metadata_repository

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

  def method_missing(method, **args)
    tag = args[:tag] || Indocker::ImageMetadata::DEFAULT_TAG

    find_by_repo(method, tag: tag)
  end
end