class Indocker::ContainerMetadata
  attr_reader :name, :attach

  module States
    CREATED    = 'created'
    RESTARTING = 'restarting'
    RUNNING    = 'running'
    PAUSED     = 'paused'
    EXITED     = 'exited'
    DEAD       = 'dead'

    ALL = [CREATED, RESTARTING, RUNNING, PAUSED, EXITED, DEAD]
  end

  def initialize(name:, directives:, attach: false)
    @name         = name
    @directives   = directives
    @attache      = attach
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

  def volumes
    volume_directives.map(&:name)
  end

  def binds
    volume_directives.map(&:to_hash)
  end

  def env_files
    env_directives.map(&:path)
  end

  def exposed_ports
    expose_directives.map(&:port) + ports_directives.map(&:container_port)
  end

  def port_bindings
    ports_directives.map(&:to_hash)
  end

  def command
    directive = @directives.detect {|c| c.instance_of?(Indocker::ContainerDirectives::Cmd)}
    
    directive.cmd
  end

  def container_dependencies
    depends_on_directives.map(&:container_name)
  end

  def before_start_directives
    @directives.select(&:before_start?)
  end

  def after_start_directives
    @directives.select(&:after_start?)
  end

  private

  def from_directive
    @directives.detect {|c| c.instance_of?(Indocker::ContainerDirectives::From)}
  end

  def network_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::Network)}
  end

  def env_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::EnvFile)}
  end

  def expose_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::Expose)}
  end

  def ports_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::Ports)}
  end

  def depends_on_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::DependsOn)}
  end

  def volume_directives
    @directives.select {|d| d.instance_of?(Indocker::ContainerDirectives::Volume)}
  end
end