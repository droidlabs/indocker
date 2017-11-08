module Indocker::ImageHelper
  DEFAULT_TAG = 'latest'

  def full_name(repo, tag = nil)
    tag ||= DEFAULT_TAG

    "#{repo}:#{tag}"
  end
end