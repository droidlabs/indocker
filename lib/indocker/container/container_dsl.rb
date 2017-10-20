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
end