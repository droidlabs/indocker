class Indocker::Git::GitService
  include SmartIoC::Iocify

  bean :git_service

  inject :git_api

  def update(repository:, revision:, workdir:)
    workdir_repository = git_api.get_remote_from_directory(workdir)

    if workdir_repository == repository
      git_api.fetch(workdir)
      git_api.checkout(revision: revision, dir: workdir)
    else
      FileUtils.rm_rf(workdir)
      
      git_api.clone(repository: repository, dir: workdir)
      git_api.checkout(revision: revision, dir: workdir)
    end
  end
end