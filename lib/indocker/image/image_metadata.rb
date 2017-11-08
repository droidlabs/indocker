class Indocker::ImageMetadata
  include Indocker::ImageHelper

  attr_reader :repo, :tag, :directives, :build_dir

  def initialize(repo:, tag:, directives:, build_dir:)
    @repo       = repo
    @tag        = tag
    @directives = directives
    @build_dir  = build_dir
  end

  def full_name
    super(@repo, @tag)
  end

  def prepare_directives
    directives.select {|d| d.prepare_directive?}
  end

  def build_directives
    directives.select {|d| d.build_directive?}
  end

  def docker_cp_directives
    directives.select {|d| d.is_a?(Indocker::PrepareDirectives::DockerCp)}
  end

  def from_repo
    from_directive.repo
  end

  def from_tag
    from_directive.tag
  end

  def dockerhub_image?
    from_directive.dockerhub_image?
  end

  private

  def from_directive
    @directives.detect {|c| c.instance_of?(Indocker::DockerDirectives::From)}
  end
end