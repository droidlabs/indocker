class Indocker::ImageMetadata
  attr_reader   :name
  attr_accessor :id

  def initialize(name, &block)
    @name            = name
    @docker_commands = []

    instance_eval &block
  end

  def to_dockerfile
    @docker_commands.join("\n")
  end

  def prepare
    @before_build || Proc.new {}
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