module Indocker::Envs
  class EnvMetadata
    def initialize(variables = {})
      @variables = variables
    end

    def to_hash
      @variables
    end

    def to_json
      to_hash.to_json
    end

    def to_array
      to_hash.inject([]) do |all, (k, v)|
        all.push "#{k}=#{v}"
      end
    end

    def set(key:, value:)
      overwritten = @variables.has_key?(key) and @variables[key] != value

      @variables[key] = value

      overwritten
    end

    def +(other)
      combined_hash = to_hash.merge(other.to_hash)

      Indocker::Envs::EnvMetadata.new(combined_hash)
    end
  end
end