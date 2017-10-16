class Indocker::ContainerDirectives::From < Indocker::ContainerDirectives::Base
  attr_accessor :repo, :tag

  def initialize(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    @repo = repo
    @tag  = tag
  end

  def image
    "#{@repo}:#{@tag}"
  end
end