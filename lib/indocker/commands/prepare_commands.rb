module Indocker::PrepareCommands
  class DockerCp
    attr_reader :container_name, :copy_actions, :build_dir

    def initialize(container_name, build_dir, &block)
      @container_name = container_name
      @build_dir      = build_dir
      @copy_actions   = []

      instance_exec &block if block_given?
    end

    private

    def copy(from, to)
      copy_actions.push({ from: from, to: to })
    end
  end
end