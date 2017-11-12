require 'docker_registry2'

class Indocker::Registry::RegistryAPIBuilder
  include SmartIoC::Iocify

  bean :registry_api

  inject :config

  def get(registry_name)
    registry = config.docker.send(registry_name)

    Indocker::Registry::RegistryAPI.new(
      serveraddress: registry.serveraddress,
      username:      registry.username,
      password:      registry.password
    )
  end
end

class Indocker::Registry::RegistryAPI
  def initialize(serveraddress:, username:, password:)
    @serveraddress = serveraddress
    @username      = username
    @password      = password
  end

  def rmtag(repo, tag: nil)
    tag ||= 'latest'

    registry.rmtag(repo, tag)
  end

  private

  def registry
    @registry ||= DockerRegistry2.connect(@serveraddress, connection_options)
  end

  def connection_options
    {
      username: @username,
      password: @password
    }.delete_if {|_, value| value.to_s.empty?}
  end
end