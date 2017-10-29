module Indocker::Git
  class GitHelper
    include SmartIoC::Iocify

    bean :git_helper

    def method_missing(method, *args)

    end
  end
end