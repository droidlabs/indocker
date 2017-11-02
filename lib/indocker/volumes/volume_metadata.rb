module Indocker::Volumes
  class VolumeMetadata
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
  end
end