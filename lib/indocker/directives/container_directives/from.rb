class Indocker::ContainerDirectives::From < Indocker::ContainerDirectives::Base
  include Indocker::ImageHelper

  attr_accessor :repo, :tag

  def initialize(repo, tag: Indocker::ImageHelper::DEFAULT_TAG)
    @repo = repo
    @tag  = tag
  end

  def image
    full_name(@repo, @tag)
  end
end