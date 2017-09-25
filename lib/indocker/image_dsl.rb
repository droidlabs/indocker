class Indocker::ImageDSL
  attr_reader :commands

  def initialize(context)
    @context  = context
    @commands = []
  end

  def method_missing(method, *args)
    @context.send(method)
  rescue
    super
  end

  def set_arg(key, value)
    @context.set_value(key, value)
  end

  def partial(name, opts = {})
    @commands << Indocker::Commands::Partial.new(name, @context, opts)
  end

  def before_build(&block)
    @commands << Indocker::Commands::BeforeBuild.new(&block)
  end
  
  def from(*args)
    @commands << Indocker::Commands::From.new(*args)
  end
  
  def workdir(*args)
    @commands << Indocker::Commands::Workdir.new(*args)
  end

  def run(*args)
    @commands << Indocker::Commands::Run.new(*args)
  end
end