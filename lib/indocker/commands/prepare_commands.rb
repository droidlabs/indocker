module Indocker::PrepareCommands
  class DockerCp
    attr_reader :container_name, :copy_actions

    def initialize(container_name, &block)
      @container_name = container_name
      @copy_actions   = []

      instance_exec &block if block_given?
    end

    private

    def copy(from, to)
      copy_actions.push({ from: from, to: to })
    end
  end
end