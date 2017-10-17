class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  inject :config_locator
  inject :docker_api
  inject :registry_authenticator
  # inject :env_files_loader


  def init_app(current_path)
    docker_api.check_docker_installed!

    load config_locator.locate(config_path)

    registry_authenticator.authenticate!

    # env_files_loader.load

    # load partials, images and containers configurations
  end
end