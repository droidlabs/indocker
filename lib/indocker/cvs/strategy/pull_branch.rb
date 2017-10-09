require_relative '../utils/local_git.rb'
require_relative 'pull.rb'

class PullBranch < Pull
  include LocalGit

  attr_reader :repository_name, :branch_name, :work_dir

  def initialize(repository_name, branch_name, work_dir)
    @repository_name = repository_name
    @branch_name = branch_name
    @work_dir = work_dir
  end

  def use
    clean_if_exist(File.join(@work_dir, LocalGit::BRANCHES, @branch_name))
    clone(@repository_name, @branch_name, File.join(@work_dir, LocalGit::BRANCHES))
    pull(remote = LocalGit::ORIGIN, branch_name = @branch_name)
  end

end
