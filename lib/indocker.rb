require 'indocker/utils/shell_commands'
require 'indocker/utils/docker_commands'

require 'indocker/image_metadata'
require 'indocker/image_build_service'
require 'indocker/container_metadata'
require 'indocker/container_runner_service'

module Indocker
  DOCKERFILE_NAME = 'Dockerfile'

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

    def container(container_name, from:)
      containers << Indocker::ContainerMetadata.new(container_name, from: from)
    end

    def build_dir(root)
      File.expand_path(root, '.indocker/tmp/build')
    end
  end
end