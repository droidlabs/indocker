class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  inject :config_locator
  inject :docker_api
  inject :registry_authenticator
  inject :config


  def init_app(current_path, env: :development)
    docker_api.check_docker_installed!

    require(config_locator.locate(current_path))

    # registry_authenticator.authenticate!()
  end
end