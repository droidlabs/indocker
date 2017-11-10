class Indocker::RegistryAvaliabilityChecker
  include SmartIoC::Iocify

  bean :registry_authenticator

  inject :config
  inject :docker_api

  def authenticate!(serveraddress:, username:, email:, password:)
    docker_api.authenticate!(
      serveraddress: serveraddress,
      username:      username,
      email:         email,
      password:      password
    )
  rescue Docker::Error::AuthenticationError
    raise Indocker::Errors::DockerRegistryAuthenticationError
  end
end