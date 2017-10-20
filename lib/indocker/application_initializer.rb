class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  inject :config_locator
  inject :docker_api
  inject :registry_authenticator
  inject :envs_manager
  inject :config


  def init_app(current_path, env: :development)
    docker_api.check_docker_installed!

    config.root(
      Pathname.new(
        File.expand_path(
          File.join(config_locator.locate(current_path), '../..')
        )
      )
    )

    require(config_locator.locate(current_path))

    registry_authenticator.authenticate!

    envs_manager.load_init_application_env_variables
  end
end