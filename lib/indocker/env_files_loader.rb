class Indocker::EnvFilesLoader
  include SmartIoC::Iocify

  bean :env_files_loader

  inject :config
  inject :logger

  def load!(env)
    if !config.load_env_file
      logger.warn "Config files were not loaded, set :load_env_file for Indocker config"
      return 
    end

    environment_file = File.join(config.root, config.load_env_file, "#{env}.env")

    logger.warn "" if !File.exists?(environment_file)

    File.foreach(environment_file) do |line|
      key, value = line.split('=').map(&:strip)
      
      if ENV.has_key?(key) && ENV[key] != value
        logger.warn "Environment file '#{environment_file}' overwrites ENV['#{key}'] from '#{ENV[key]}' to '#{value}'!"
      end
      
      ENV[key] = value
    end
  end
end