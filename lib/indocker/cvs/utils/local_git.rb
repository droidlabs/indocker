require 'git'

module LocalGit

  BRANCHES  = "branches"  .freeze
  TAGS      = "tags"      .freeze
  REVISIONS = "revisions" .freeze
  MASTER    = "master"    .freeze
  ORIGIN    = "origin"    .freeze

  attr_reader :git

  def clone(repository_name, app_name, working_dir)
    @git = Git.clone(repository_name, app_name, :path => working_dir)
  end

  def pull(remote = 'origin', branch_name = 'master')
    raise InitializationError.new("pull") unless @git
    @git.pull(remote, branch_name)
  end

  def checkout(branch_name, opt = {})
    raise InitializationError.new("checkout") unless @git
    @git.checkout(branch_name, opt) 
  end

  def delete(branch_name)
    raise InitializationError.new("delete") unless @git
    @git.branch(branch_name).delete
  end

  class InitializationError < StandardError
    def initialize(message)
      super(message + ' called before initialization')
    end
  end
  
end
