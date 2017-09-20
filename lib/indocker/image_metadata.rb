class Indocker::ImageMetadata
  DEFAULT_TAG = 'latest'

  attr_reader   :repository, :tag
  attr_accessor :id

  def initialize(repository, &block)
    @repository      = repository
    @tag             = DEFAULT_TAG

    @docker_commands = []

    instance_eval &block
  end

  def full_name
    "#{repository}:#{tag}"
  end

  def to_dockerfile
    @docker_commands.join("\n")
  end

  def before_build_block
    @before_build || Proc.new {}
  end

  def build_dir
    File.expand_path(File.join(Indocker::BUILD_DIR, repository))
  end

  private 

  def before_build(&block)
    @before_build = block
  end

  def from(image_name)
    @docker_commands.push("FROM #{image_name.to_s}")
  end

  def run(command)
    @docker_commands.push("RUN #{command.to_s}")
  end

  def cmd(command)
    @docker_commands.push("CMD #{command.to_s}")
  end

  def copy(from, to)
    @docker_commands.push("COPY #{from.to_s} #{to.to_s}")
  end

  def workdir(path)
    @docker_commands.push("WORKDIR #{path.to_s}")
  end

  def entrypoint(command)
    @docker_commands.push("ENTRYPOINT #{command.to_s}")
  end
end