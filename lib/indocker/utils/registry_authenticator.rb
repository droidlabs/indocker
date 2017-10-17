class Indocker::RegistryAvaliabilityChecker
  include SmartIoC::Iocify

  bean :registry_authenticator

  inject :config
  inject :docker_api

  def authenticate!
    docker_api.authenticate!(
      serveraddress: config.docker.registry,
      username:      config.docker.username,
      email:         config.docker.email,
      password:      config.docker.password
    )
  rescue Docker::Error::AuthenticationError
    raise Indocker::Errors::DockerRegistryAuthenticationError
  end
end