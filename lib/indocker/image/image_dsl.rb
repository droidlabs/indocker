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
    @commands << Indocker::Directives::Partial.new(name, @context, opts)
  end
  
  def from(*args)
    @commands << Indocker::DockerDirectives::From.new(*args)
  end
  
  def workdir(*args)
    @commands << Indocker::DockerDirectives::Workdir.new(*args)
  end

  def run(*args)
    @commands << Indocker::DockerDirectives::Run.new(*args)
  end

  def cmd(*args)
    @commands << Indocker::DockerDirectives::Cmd.new(*args)
  end

  def copy(*args)
    @commands << Indocker::DockerDirectives::Copy.new(*args)
  end

  def entrypoint(*args)
    @commands << Indocker::DockerDirectives::Entrypoint.new(*args)
  end

  def env(*args)
    @commands << Indocker::DockerDirectives::Env.new(args)
  end

  def before_build(&block)
    instance_exec @context.build_dir, &block
  end

  def docker_cp(container_name, &block)
    @commands << Indocker::PrepareDirectives::DockerCp.new(container_name, @context.build_dir, &block)
  end
end