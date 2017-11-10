class Indocker::Configs::ConfigFactory
  include SmartIoC::Iocify

  bean :config, factory_method: :build

  CONFIG_STRUCTURE = Proc.new do
    option :namespace, group: :common, type: :symbol
    option :build_dir, group: :common, type: :pathname

    option :load_env_file,      group: :load, type: :array
    option :load_docker_items,  group: :load, type: :array

    config :git, group: :git do
      option :cache_dir, group: :common, type: :pathname
    
      hash_config :repo do
        option :repository
        option :tag
        option :branch
      end
    end

    config :docker, group: :docker do
      hash_config :registry do
        option :serveraddress
        option :email
        option :password
        option :username
        option :skip_push, type: :boolean
      end
    end
  end

  def build(&block)    
    @configuration ||= Indocker::Configs::Config.new.set(&CONFIG_STRUCTURE)
  end
end