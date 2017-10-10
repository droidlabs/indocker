class DSLGit 

  attr_reader :repo_name, :tag_name, :branch_name, :work_dir

  def initialize(&block)
    raise InitializationError unless block_given?
    instance_eval &block
    execute
  end

  def repository(name)
    @repo_name = name
  end

  def tag(name)
    @tag_name = name
  end

  def branch(name)
    @branch_name = name
  end

  def work_dir(name)
    @work_dir = name
  end

  def execute
    vcs = VersionControlSystem.new(@repo_name, @branch_name, @tag_name, @work_dir)
    vcs.use
  end

  class InitializationError < StandardError
    def initialize()
      super("Block is empty")
    end
  end

end