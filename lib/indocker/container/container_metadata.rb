class Indocker::ContainerMetadata
  attr_reader :name

  module States
    CREATED    = 'created'
    RESTARTING = 'restarting'
    RUNNING    = 'running'
    PAUSED     = 'paused'
    EXITED     = 'exited'
    DEAD       = 'dead'

    ALL = [CREATED, RESTARTING, RUNNING, PAUSED, EXITED, DEAD]
  end

  def initialize(name:, directives:)
    @name         = name
    @directives   = directives
  end

  def repo
    from_directive.repo
  end

  def tag
    from_directive.tag
  end

  def image
    from_directive.image
  end

  def networks
    network_directives.map(&:name)
  end

  def before_start_directives
    @directives.select(&:before_start?)
  end

  private

  def from_directive
    @directives.detect {|c| c.instance_of?(Indocker::ContainerDirectives::From)}
  end

  def network_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::Network)}
  end
end