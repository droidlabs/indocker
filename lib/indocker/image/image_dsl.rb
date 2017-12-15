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

  def expose(port)
    @directives << Indocker::ImageDirectives::Expose.new(port)
  end
  
  def from(*args)
    first_from_directive = @directives.detect {|c| c.instance_of?(Indocker::ImageDirectives::From)}
    raise Indocker::Errors::DirectiveAlreadyInUse, first_from_directive if first_from_directive

    @directives << Indocker::ImageDirectives::From.new(*args)
  end

  def use(item)
    case item
    when Indocker::Registry::RegistryHelper
      first_from_directive = @directives.detect {|c| c.instance_of?(Indocker::ImageDirectives::Registry)}
      raise Indocker::Errors::DirectiveAlreadyInUse, first_from_directive if first_from_directive

      @directives << Indocker::ImageDirectives::Registry.new(
        repo:     repo,
        tag:      tag,
        registry: item.registry, 
        push:     item.push
      )
    end
  end
  
  def workdir(*args)
    @directives << Indocker::ImageDirectives::Workdir.new(*args)
  end

  def run(*args)
    @directives << Indocker::ImageDirectives::Run.new(*args)
  end

  def cmd(*args)
    @directives << Indocker::ImageDirectives::Cmd.new(*args)
  end

  def copy(copy_hash = {}, compile = false)
    copy_actions = copy_hash.inject([]) do |all, (from, to)|
      all << Indocker::CopyActionDTO.new(from: from, to: to)
    end

    @directives << Indocker::ImageDirectives::Copy.new(
      compile:      compile,
      copy_actions: copy_actions,
      locals:       @context.storage,
      build_dir:    @context.build_dir
    )
  end

  def entrypoint(*args)
    @directives << Indocker::ImageDirectives::Entrypoint.new(*args)
  end

  def env(*args)
    @directives << Indocker::ImageDirectives::Env.new(args)
  end

  def env_file(*paths)
    @directives.concat paths.map {|p| Indocker::ImageDirectives::EnvFile.new(p)}
  end

  def before_build(&block)
    instance_exec &block
  end

  def docker_cp(container_name, &block)
    @directives << Indocker::ImageDirectives::DockerCp.new(container_name, @context.build_dir, @context.storage, &block)
  end
end