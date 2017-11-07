module Indocker::Volumes
  class VolumeMetadata
    attr_reader :name, :source, :target
    
    def initialize(name:, source:, target:)
      @name   = name
      @source = source
      @target = target
    end
  end
end