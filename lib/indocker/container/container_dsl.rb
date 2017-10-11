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
      @directives << Indocker::ContainerDirectives::From.new(item.repo, tag: item.tag)
    end
  end
end