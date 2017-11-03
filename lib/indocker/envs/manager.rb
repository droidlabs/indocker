class Indocker::Envs::Manager
  include SmartIoC::Iocify

  bean :envs_manager

  inject :config
  inject :logger
  inject :envs_loader

  def load_init_application_env_variables
    config.load_env_file.each do |path|
      env_file = File.expand_path File.join(config.root, '..', path)

      begin
        metadata = envs_loader.parse(env_file) 
      rescue Indocker::Errors::EnvFileDoesNotExist
        logger.warn "File #{env_file} doesn't exist. Check path to environment_path"
        return
      end

      metadata.to_hash.each do |key, value|
        if ENV.has_key?(key) && ENV[key] != value
          logger.warn "Environment file '#{path}' overwrites ENV['#{key}'] from '#{ENV[key]}' to '#{value}'!"
        end

        ENV[key] = value
      end
    end
  end
end