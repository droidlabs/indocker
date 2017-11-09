class Indocker::DockerAPI::ContainerConfig
  include Indocker::ImageHelper

  attr_reader :image, :name, :cmd, :env, :exposed_ports, :host_config, :volumes_config

  CONTAINER_DEFAULT_OPTIONS = {
    'Tty'            => true,
    'OpenStdin'      => true,
    'StdinOnce'      => true,
    'AttachStdin'    => true,
    'AttachStdout'   => true
  }

  def initialize(
    name:, 
    repo:          nil, 
    tag:           nil, 
    image:         nil,              
    cmd:           nil, 
    env:           '', 
    volumes:       [], 
    binds:         [], 
    exposed_ports: nil, 
    port_bindings: nil
  )

    @image          = image_full_name(image, repo, tag)
    @name           = name
    @cmd            = cmd
    @env            = env
    @exposed_ports  = ExposedPortsConfig.new(exposed_ports)
    @host_config    = HostConfig.new(port_bindings, binds)
    @volumes_config = VolumesConfig.new(volumes)
  end

  def ==(other)
    self.to_hash == other.to_hash
  end

  def image_full_name(image = nil, repo = nil, tag = nil)
    result = image || full_name(repo, tag)
    raise ArgumentError if result.to_s.empty?

    result
  end

  def to_hash
    state_config = {
      'Image'        => @image,
      'name'         => @name,
      'Cmd'          => @cmd,
      'Env'          => @env,
      'ExposedPorts' => @exposed_ports.to_hash,
      'Volumes'      => @volumes_config.to_hash,
      'HostConfig'   => @host_config.to_hash
    }

    CONTAINER_DEFAULT_OPTIONS
      .merge(state_config)
      .delete_if {|_, value| value.to_s.empty?}
  end

  class ExposedPortsConfig
    attr_reader :ports

    def initialize(ports)
      @ports = ports
    end

    def to_hash
      @ports.inject({}) do |result, value|
        result[value] = {}
        result
      end
    end
  end

  class VolumesConfig
    attr_reader :volumes

    VOLUME_VALUE = {}

    def initialize(volumes)
      @volumes = volumes
    end

    def to_hash
      volumes.inject({}) do |config, v|
        config[v] = {}
        config
      end
    end
  end

  class HostConfig
    attr_reader :port_bindings, :binds

    def initialize(port_bindings, binds)
      @port_bindings = port_bindings
      @binds         = binds
    end

    def to_hash
      format_port_bindings = port_bindings.inject({}) do |result, value|
        result[value[:container_port]] = [{ "HostPort" => value[:host_port] }]
        result
      end

      format_binds = binds.inject([]) do |result, value|
        result.push("#{value[:name]}:#{value[:to]}")
        result
      end

      {
        'Binds'        => format_binds,
        'PortBindings' => format_port_bindings
      }
    end
  end
end

