class Indocker::Configs::ConfigFactory
  include SmartIoC::Iocify

  bean :config, factory_method: :build

  CONFIG_STRUCTURE = Proc.new do
    option :namespace, group: :common
    option :root,      group: :common, type: :pathname

    option :load_env_file,      group: :load, type: :array
    option :load_docker_items,  group: :load, type: :array

    config :git, group: :git do
      hash_config :repo do
        option :repository
        option :tag
        option :branch
        option :workdir 
      end
    end

    config :docker, group: :docker do
      option :registry
      option :email
      option :password
      option :username
      option :skip_push, type: :boolean
    end
  end

  def build(&block)    
    return @configuration if @configuration

    @configuration = Indocker::Configs::Config.new
    @configuration.instance_exec(&CONFIG_STRUCTURE)
    @configuration
  end
end