require_relative 'strategy/pull_branch.rb'
require_relative 'strategy/pull_tag.rb'

class VersionControlSystem

  attr_reader :repository_name, :branch_name, :tag_name, :work_dir

  def initialize(repository_name, branch_name, tag_name, work_dir)
    @repository_name = repository_name
    @branch_name = branch_name
    @tag_name = tag_name
    @work_dir = work_dir
  end

  def use
    raise 'Use only one way for git pull' if parameters_is_incorrect
    strategy = nil
    if pull_via_branches
      strategy = PullBranch.new(@repository_name, @branch_name, @work_dir)
    elsif pull_via_tags
      strategy = PullTag.new(@repository_name, @tag_name, @work_dir)
    end 
    strategy.use if strategy
    strategy
  end

  def parameters_is_incorrect
    incorrect = pull_via_branches && pull_via_tags
  end

  def pull_via_tags
    is_correct = @tag_name != nil
  end

  def pull_via_branches
    is_correct = @branch_name != nil 
  end

end
