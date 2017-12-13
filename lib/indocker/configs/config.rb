module Indocker::Configs
  class Config
    attr_reader :scope

    def scope
      @scope ||= Hash.new()
    end

    def options
      scope.reject {|_, opt| opt.is_a?(Indocker::Configs::Config)}.keys
    end

    def configs
      scope.select {|_, opt| opt.is_a?(Indocker::Configs::Config)}.keys
    end

    def set(&block)
      instance_exec(&block)

      self
    end

    def option(name, group: nil, type: nil, required: nil)
      raise Indocker::Errors::ReservedKeywordUsed, name if respond_to?(name.to_sym)

      define_singleton_method(name) do |value = nil, &block|
        if type == :config and options.include?(name) and block
          return read_setting(name).set(&block)
        end

        if block || value
          write_setting(
            name:        name, 
            value:       block || value, 
            group:       group, 
            type:        type, 
            required:    required
          )
        else
          read_setting(name)
        end
      end
    end

    def config(name, group: :default, &block)
      raise Indocker::Errors::ReservedKeywordUsed, name if respond_to?(name.to_sym)

      subconfiguration = Indocker::Configs::Config.new
      subconfiguration.instance_exec(&block)
  
      option(name, group: group, type: :config)
      send(name, subconfiguration)

      subconfiguration
    end

    def hash_config(hash_config_name, group: :default, &hash_config_block)
      raise Indocker::Errors::ReservedKeywordUsed, hash_config_name if respond_to?(hash_config_name.to_sym)

      define_singleton_method(hash_config_name) do |name, &self_block|
        config = config(name, &hash_config_block)
        config.set(&self_block)
        
        config
      end
    end

    private

    def read_setting(name)
      read_value = scope.has_key?(name.intern) ? scope[name.intern].value : nil
      
      read_value.is_a?(Proc) ? read_value.call : read_value
    end

    def write_setting(name:, value:, group:, type:, required:)
      new_option = Option.new(
        name:     name,
        value:    value,
        group:    group,
        required: required,
        type:     type
      )

      new_option.validate!

      scope[name.intern] = new_option
    end


    def method_missing(method, *args, &block)
      raise "Undefined keyword #{method.inspect} for Indocker configuration file"
    end
  end
end