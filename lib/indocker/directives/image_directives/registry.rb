class Indocker::ImageDirectives::Registry < Indocker::ImageDirectives::Base
  attr_reader :registry, :push, :repo, :tag

  def initialize(repo:, tag:, registry:, push:)
    @repo     = repo.to_s
    @tag      = tag.to_s
    @registry = format_registry(registry)
    @push     = push
  end

  def new_repo
    "#{@registry}/#{@repo}"
  end

  def new_tag
    @tag
  end

  def after_build_directive?
    true
  end

  private

  def format_registry(serveraddress)
    serveraddress
      .gsub('http://', '')
      .gsub(/\/\Z/, '')
  end
end