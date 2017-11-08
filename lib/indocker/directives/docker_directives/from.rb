class Indocker::DockerDirectives::From < Indocker::DockerDirectives::Base
  include Indocker::ImageHelper

  attr_reader :repo, :tag

  def initialize(repo_tag, tag: nil)
    case repo_tag
    when String
      @repo = repo_tag.split(':')[0]
      @tag  = tag || repo_tag.split(':')[1] || Indocker::ImageHelper::DEFAULT_TAG
    else
      @repo = repo_tag
      @tag  = tag || Indocker::ImageHelper::DEFAULT_TAG
    end
  end

  def full_name
    super(@repo, @tag)
  end

  def dockerhub_image?
    repo.is_a?(String)
  end

  def to_s
    "#{type} #{full_name}"
  end

  def type
    'FROM'
  end
end