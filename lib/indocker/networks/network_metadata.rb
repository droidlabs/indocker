module Indocker::Networks
  class NetworkMetadata
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
  end
end