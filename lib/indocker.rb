require 'smart_ioc'
require 'docker-api'
require 'logger'

SmartIoC.find_package_beans(:indocker, __dir__)

require 'indocker/utils/ioc_container'
require 'indocker/utils/shell_commands'
require 'indocker/utils/docker_commands'
require 'indocker/utils/test_logger'
require 'indocker/utils/logger_factory'
require 'indocker/utils/test_logger_factory'
require 'indocker/utils/docker_api'

require 'indocker/image_metadata'
require 'indocker/image_repository'
require 'indocker/image_prepare_service'
require 'indocker/image_build_service'
require 'indocker/image_dependencies_manager'
require 'indocker/image_pusher'

require 'indocker/container_metadata'
require 'indocker/container_repository'
require 'indocker/container_runner_service'

require 'indocker/errors'

module Indocker
  DOCKERFILE_NAME = 'Dockerfile'
  BUILD_DIR       = 'tmp/build'

  class << self
    def images
      @images ||= []
    end

    def image(name, &block)
      images << Indocker::ImageMetadata.new(name, &block) 
    end

    def containers
      @containers ||= []
    end

    def container(container_name, from_repo:, from_tag: Indocker::ImageMetadata::DEFAULT_TAG)
      containers << Indocker::ContainerMetadata.new(container_name, from_repo: from_repo, from_tag: from_tag)
    end

    def logger
      @logger ||= ioc.logger
    end

    def root(dir = nil)
      return @root if @root

      @root = dir
    end
  end
end