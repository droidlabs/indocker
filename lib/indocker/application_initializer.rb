class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  inject :config_locator
  inject :docker_api
  inject :registry_authenticator
  inject :env_files_loader
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

    load(config_locator.locate(current_path))

    registry_authenticator.authenticate!

    env_files_loader.load!(env)
  end
end