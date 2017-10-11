class Indocker::ContainerMetadata
  attr_reader :name
  attr_accessor :container_id

  def initialize(name:, directives:, container_id:)
    @name         = name
    @directives   = directives
    @container_id = container_id
  end

  def repo
    from_directive.repo
  end

  def tag
    from_directive.tag
  end

  def image
    "#{repo}:#{tag}"
  end

  private

  def from_directive
    @directives.detect {|c| c.instance_of?(Indocker::ContainerDirectives::From)}
  end
end