class Indocker::ContainerMetadata
  attr_reader :name

  HOSTPORT = 'HostPort'

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

  def env_files
    env_directives.map(&:path)
  end

  def exposed_ports
    return nil if ports_directives.empty? && expose_directives.empty?

    result = Hash.new

    expose_directives.each do |d|
      result[d.port.to_s] = {}
    end

    ports_directives.each do |d|
      result[d.docker_port] = {}
    end

    result
  end

  def port_bindings
    return nil if ports_directives.empty?

    result = Hash.new

    ports_directives.each do |d|
      result[d.docker_port] = [{ HOSTPORT => d.host_port }]
    end

    result
  end

  def container_dependencies
    depends_on_directives.map(&:container_name)
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
end