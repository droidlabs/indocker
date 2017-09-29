class Indocker::ContainerMetadata
  attr_reader :name, :from_repo, :from_tag
  attr_accessor :id

  def initialize(name, from_repo:, from_tag: Indocker::ImageMetadata::DEFAULT_TAG)
    @name      = name
    @from_repo = from_repo
    @from_tag  = from_tag
  end

  def from_image
    "#{from_repo}:#{from_tag}"
  end
end