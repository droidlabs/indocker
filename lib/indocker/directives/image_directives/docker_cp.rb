class Indocker::ImageDirectives::DockerCp < Indocker::ImageDirectives::Base
  attr_reader :container_name, :copy_actions, :build_dir

  def initialize(container_name, build_dir, &block)
    @container_name = container_name
    @build_dir      = build_dir

    instance_exec &block if block_given?
  end

  def prepare_directive?
    true
  end

  private

  def copy(copy_actions)
    @copy_actions = copy_actions
  end
end