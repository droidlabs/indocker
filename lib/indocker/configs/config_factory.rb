class Indocker::Configs::ConfigFactory
  include SmartIoC::Iocify

  bean :config, factory_method: :build

  CONFIG_STRUCTURE = Proc.new do
    option :namespace,    group: :common, type: :symbol
    option :build_dir,    group: :common, type: :pathname
    option :root_dir,     group: :common, type: :pathname
    option :template_dir, group: :common, type: :pathname
    
    option :env_file,     group: :common, type: :string

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
        option :serveraddress, required: true
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