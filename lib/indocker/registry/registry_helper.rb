module Indocker::Registry
  class RegistryHelper
    include Indocker::ImageHelper

    attr_reader :push, :registry

    def initialize(registry:, push: false)
      @registry = registry
      @push     = push
    end

    def to_s
      registry
    end

    def get(repository, tag: nil)
      "#{registry}/#{full_name(repository, tag)}"
    end
  end
end