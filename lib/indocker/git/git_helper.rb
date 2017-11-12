module Indocker::Git
  class GitHelper
    include SmartIoC::Iocify

    bean :git_helper

    inject :config
    inject :git_service

    def method_missing(method, *args)
      git_config    = config.git.send(method)
      git_cache_dir = config.git.cache_dir.join(method.to_s)

      return git_cache_dir if updated?(git_config.repository)

      git_service.update(
        repository: git_config.repository,
        revision:   git_config.branch || git_config.tag,
        workdir:    git_cache_dir
      )
      git_cache.push(git_config.repository)

      Pathname.new(git_cache_dir)
    end

    def git_cache
      @git_cache ||= []
    end

    def updated?(url)
      git_cache.include?(url)
    end
  end
end