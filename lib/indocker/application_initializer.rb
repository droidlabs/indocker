class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  inject :config_locator
  inject :docker_api
  inject :registry_authenticator
  inject :config
  inject :envs_loader


  def init_app(current_path, env: :development)
    docker_api.check_docker_installed!

    require(config_locator.locate(current_path))

    ENV.update( envs_loader.parse(File.join(current_path, config.env_file)).to_hash )
    debugger
    # registry_authenticator.authenticate!()
  end
end