class Indocker::ImageDSL
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

  def set_arg(key, value)
    @context.set_value(key, value)
  end

  def partial(name, opts = {})
    @directives << Indocker::Directives::Partial.new(name, @context, opts)
  end
  
  def from(*args)
    @directives << Indocker::DockerDirectives::From.new(*args)
  end
  
  def workdir(*args)
    @directives << Indocker::DockerDirectives::Workdir.new(*args)
  end

  def run(*args)
    @directives << Indocker::DockerDirectives::Run.new(*args)
  end

  def cmd(*args)
    @directives << Indocker::DockerDirectives::Cmd.new(*args)
  end

  def copy(*args)
    @directives << Indocker::DockerDirectives::Copy.new(*args)
  end

  def entrypoint(*args)
    @directives << Indocker::DockerDirectives::Entrypoint.new(*args)
  end

  def env(*args)
    @directives << Indocker::DockerDirectives::Env.new(args)
  end

  def before_build(&block)
    instance_exec @context.build_dir, &block
  end

  def docker_cp(container_name, &block)
    @directives << Indocker::PrepareDirectives::DockerCp.new(container_name, @context.build_dir, &block)
  end

  def cp_r(copy_hash)
    @directives << Indocker::PrepareDirectives::Copy.new(@context.build_dir, copy_hash)
  end
end