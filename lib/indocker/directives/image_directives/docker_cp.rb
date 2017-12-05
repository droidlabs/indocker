class Indocker::ImageDirectives::DockerCp < Indocker::ImageDirectives::Base
  attr_reader :container_name, :copy_actions, :build_dir

  def initialize(container_name, build_dir, dsl_hash = {}, &block)

    @container_name = container_name
    @build_dir      = build_dir

    return unless block_given?
    
    @copy_actions = DSLContext.new(dsl_hash).tap { |c| c.instance_eval(&block) }.copy_actions
  end

  def prepare_directive?
    true
  end

  class DSLContext < Indocker::DSLContext
    attr_reader :copy_actions

    def copy(copy_actions)
      @copy_actions = copy_actions
    end
  end
end

