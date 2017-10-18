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
end