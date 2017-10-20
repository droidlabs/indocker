require 'timeout'

class Indocker::ContainerDirectivesRunner
  include SmartIoC::Iocify

  bean :container_directives_runner

  inject :docker_api
  inject :config

  def run_all(directives)
    directives.each {|c| run(c)}
  end

  def run(directive)
    case directive
    when Indocker::ContainerDirectives::Network
      run_network(directive)
    when Indocker::ContainerDirectives::Ready
      run_ready(directive)
    else
      # do nothing
    end
  end

  def run_network(directive)
    if !docker_api.network_exists?(directive.network_name)
      docker_api.create_network(directive.network_name)
    end

    docker_api.add_container_to_network(
      container_name: directive.container_name,
      network_name:   directive.network_name
    )
  end

  def run_ready(directive)
    Timeout::timeout(directive.timeout) do
      while (!directive.ready_block.call)
        sleep directive.sleep
      end
    end
  rescue Timeout::Error
    raise Indocker::Errors::ContainerTimeoutError
  end
end