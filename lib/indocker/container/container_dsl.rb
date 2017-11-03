class Indocker::ContainerDSL
  attr_reader :directives

  def initialize(context)
    @context  = context
    @directives = []
  end

  def method_missing(method, *args)
    @context.send(method)
  rescue
    super
  end

  private

  def use(item)
    case item
    when Indocker::ImageMetadata
      from_directive = @directives.detect {|d| d.instance_of?(Indocker::ContainerDirectives::From)}
      raise Indocker::Errors::ContainerImageAlreadyDefined, from_directive.image if from_directive
        
      @directives << Indocker::ContainerDirectives::From.new(item.repo, tag: item.tag)
    when Indocker::Networks::NetworkMetadata
      @directives << Indocker::ContainerDirectives::Network.new(
        container_name: @context.container_name,
        network_name:   item.name
      )
    end
  end

  def mount(volume, to:)
    @directives << Indocker::ContainerDirectives::Volume.new(
      volume_name: volume,
      to:          to
    ) 
  end

  def cmd(*command)
    first_cmd_directive = @directives.detect {|c| c.instance_of?(Indocker::ContainerDirectives::Cmd)}
    raise Indocker::Errors::DirectiveAlreadyInUse, first_cmd_directive if first_cmd_directive

    @directives << Indocker::ContainerDirectives::Cmd.new(command)
  end

  def env_file(path)
    @directives << Indocker::ContainerDirectives::EnvFile.new(path)
  end

  def expose(port)
    @directives << Indocker::ContainerDirectives::Expose.new(path)
  end

  def ports(ports)
    docker_port, host_port = ports.split(':').map(&:strip)

    @directives << Indocker::ContainerDirectives::Ports.new(
      docker_port: docker_port, 
      host_port:   host_port
    )
  end

  def depends_on(container_metadata)
    @directives << Indocker::ContainerDirectives::DependsOn.new(container_metadata.name)
  end

  def ready(sleep:, timeout:, &ready_block)
    @directives << Indocker::ContainerDirectives::Ready.new(
      sleep:       sleep,
      timeout:     timeout,
      ready_block: ready_block
    )
  end
end