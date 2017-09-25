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
require 'indocker/image_dsl'
require 'indocker/image_context'
require 'indocker/image_repository'
require 'indocker/image_prepare_service'
require 'indocker/image_build_service'
require 'indocker/image_dependencies_manager'
require 'indocker/image_evaluator'

require 'indocker/container_metadata'
require 'indocker/container_repository'
require 'indocker/container_runner_service'

require 'indocker/partial'
require 'indocker/partial_repository'

require 'indocker/errors'
require 'indocker/commands'

module Indocker
  DOCKERFILE_NAME = 'Dockerfile'
  BUILD_DIR       = 'tmp/build'

  class << self
    def images
      @images ||= []
    end

    def define_image(name, &definition)
      images << Indocker::ImageMetadata.new(name, &definition) 
    end

    def containers
      @containers ||= []
    end

    def define_container(name, from_repo:, from_tag: Indocker::ImageMetadata::DEFAULT_TAG)
      containers << Indocker::ContainerMetadata.new(name, from_repo: from_repo, from_tag: from_tag)
    end

    def partials
      @partials ||= []
    end

    def define_partial(name, &definition)
      partials << Indocker::Partial.new(name, &definition)
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