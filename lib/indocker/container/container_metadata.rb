class Indocker::ContainerMetadata
  attr_reader :name, :repo, :tag
  attr_accessor :container_id

  def initialize(name:, repo:, tag:, container_id: nil)
    @name         = name
    @repo         = repo
    @tag          = tag
    @container_id = container_id
  end

  def image
    "#{repo}:#{tag}"
  end
end