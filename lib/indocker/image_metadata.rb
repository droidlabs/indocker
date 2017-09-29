class Indocker::ImageMetadata
  DEFAULT_TAG = 'latest'

  attr_reader   :repo, :tag, :commands, :build_dir
  attr_accessor :image_id

  def initialize(repo:, tag:, commands:, build_dir:, image_id:)
    @repo      = repo
    @tag       = tag
    @commands  = commands
    @build_dir = build_dir
    @image_id  = image_id
  end

  def full_name
    "#{repo}:#{tag}"
  end

  def full_name_with_registry
    "#{Indocker.config.registry}/#{local_full_name}"
  end

  def prepare_commands
    @commands.select {|c| c.instance_of?(Indocker::PrepareCommands::DockerCp)}
  end

  def build_commands
    @commands.reject {|c| c.instance_of?(Indocker::PrepareCommands::DockerCp)}
  end

  def from_image
    @commands
      .detect {|c| c.instance_of?(Indocker::Commands::From)}
      .full_name
  end

  def dockerhub_image?
    @commands
      .detect {|c| c.instance_of?(Indocker::Commands::From)}
      .dockerhub_image?
  end
end