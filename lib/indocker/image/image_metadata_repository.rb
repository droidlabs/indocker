class Indocker::ImageMetadataRepository
  include SmartIoC::Iocify
  
  bean :image_metadata_repository

  def find_by_repo(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    image_metadata = Indocker.images.detect do |im| 
      im.full_name == full_name(repo, tag: tag)
    end
    raise Indocker::Errors::ImageIsNotDefined, full_name(repo, tag: tag) if image_metadata.nil?

    image_metadata
  end

  private

  def full_name(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    "#{repo}:#{tag}"
  end
end