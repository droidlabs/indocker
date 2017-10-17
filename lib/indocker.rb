require 'smart_ioc'
require 'docker-api'
require 'logger'

SmartIoC.find_package_beans(:indocker, __dir__)
SmartIoC.set_load_proc do |location|
  require(location)
end

Docker.options = { read_timeout: 600, write_timeout: 600 }

require 'indocker/errors'
require 'indocker/cli'
require 'indocker/docker_api'
require 'indocker/dsl_context'

require 'indocker/configs/config'
require 'indocker/configs/config_factory'
require 'indocker/configs/locator'

require 'indocker/utils/logger'
require 'indocker/utils/logger_factory'
require 'indocker/utils/test_logger_factory'
require 'indocker/utils/tar_helper'
require 'indocker/utils/string_utils'
require 'indocker/utils/registry_authenticator'

require 'indocker/handlers/base'
require 'indocker/handlers/run_container'

require 'indocker/utils/ioc_container'

require 'indocker/image/image_metadata'
require 'indocker/image/image_metadata_factory'
require 'indocker/image/image_dsl'
require 'indocker/image/image_metadata_repository'
require 'indocker/image/image_builder'
require 'indocker/image/image_dependencies_manager'
require 'indocker/image/image_evaluator'

require 'indocker/container/container_metadata'
require 'indocker/container/container_metadata_repository'
require 'indocker/container/container_metadata_factory'
require 'indocker/container/container_manager'
require 'indocker/container/container_evaluator'
require 'indocker/container/container_dsl'

require 'indocker/partial/partial_metadata'
require 'indocker/partial/partial_metadata_repository'

require 'indocker/directives/directives_runner'
require 'indocker/directives/base'
require 'indocker/directives/partial'

require 'indocker/directives/docker_directives/base'
require 'indocker/directives/docker_directives/cmd'
require 'indocker/directives/docker_directives/entrypoint'
require 'indocker/directives/docker_directives/env'
require 'indocker/directives/docker_directives/copy'
require 'indocker/directives/docker_directives/copy_root'
require 'indocker/directives/docker_directives/from'
require 'indocker/directives/docker_directives/run'
require 'indocker/directives/docker_directives/workdir'

require 'indocker/directives/prepare_directives/base'
require 'indocker/directives/prepare_directives/docker_cp'

require 'indocker/directives/container_directives/base'
require 'indocker/directives/container_directives/from'

module Indocker
  DOCKERFILE_NAME = 'Dockerfile'
  BUILD_DIR       = 'tmp/build'

  class << self
    def define_image(name, &definition)
      ioc.image_metadata_repository.put(
        ioc.image_metadata_factory.create(name, &definition)
      )
    end

    def define_container(name, &definition)
      ioc.container_metadata_repository.put(
        ioc.container_metadata_factory.create(name, &definition)
      )
    end

    def define_partial(name, &definition)
      ioc.partial_metadata_repository.put(
        Indocker::PartialMetadata.new(name, &definition)
      )
    end

    def setup(&block)
      ioc.config(&block)
    end

    def root(dir = nil)
      return @root if @root

      @root = Pathname.new(dir)
    end
  end
end