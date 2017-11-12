class Indocker::Registry::RegistryService
  include SmartIoC::Iocify

  bean :registry_service

  inject :config

  def method_missing(method, *args)
    if !config.docker.respond_to?(method)
      raise ArgumentError, "Registry #{method} is not defined. Add it to config.docker section"
    end

    registry_config = config.docker.send(method)

    Indocker::Registry::RegistryHelper.new(
      registry: registry_config.serveraddress,
      push:     args.first[:push]
    )
  end

  def get(registry)
    if !config.docker.respond_to?(method)
      raise ArgumentError, "Registry #{method} is not defined. Add it to config.docker section"
    end
    
    config.docker.send(method).serveraddress
  end
end