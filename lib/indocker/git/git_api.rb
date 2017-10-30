require 'git'

class Indocker::Git::GitAPI
  include SmartIoC::Iocify

  bean :git_api

  DEFAULT_REMOTE = 'origin'
  
  def get_remote_from_directory(dir)
    Git.open(dir).remote(DEFAULT_REMOTE).url
  rescue ArgumentError
    nil
  end

  def fetch(dir)
    Git.open(dir).fetch
  end

  def clone(repository:, dir:)
    dir = File.expand_path(dir)

    git_path = File.dirname(dir)
    app_name = File.basename(dir)

    Git.clone(repository, app_name, path: git_path)
  end

  def checkout(revision:, dir:)
    Git.open(dir).checkout(revision)
  end
end