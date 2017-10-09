require_relative '../utils/local_git.rb'
require_relative 'pull.rb'

class PullTag < Pull
  include LocalGit

  attr_reader :repository_name, :tag_name, :work_dir

  def initialize(repository_name, tag_name, work_dir)
    @repository_name = repository_name
    @tag_name = tag_name
    @work_dir = work_dir
  end

  def use
    clean_if_exist(File.join(@work_dir, LocalGit::TAGS, @tag_name))
    clone(@repository_name, @tag_name, File.join(@work_dir, LocalGit::TAGS))
    checkout(@tag_name)
    delete(LocalGit::MASTER)
    checkout(LocalGit::MASTER, { :b => true })
  end

end
