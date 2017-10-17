class Indocker::DirectivesRunner
  include SmartIoC::Iocify

  bean :directives_runner

  inject :container_manager
  inject :config

  def run_all(directives)
    directives.each {|c| run(c)}
  end

  def run(directive)
    case directive
    when Indocker::PrepareDirectives::DockerCp
      run_docker_cp(directive)
    when Indocker::DockerDirectives::CopyRoot
      run_copy_root(directive)
    end
  end

  def run_docker_cp(directive)
    directive.copy_actions.each do |from, to|
      container_manager.copy(
        name:      directive.container_name,
        copy_from: from,
        copy_to:   to
      )
    end
  end

  def run_copy_root(directive)
    directive.copy_actions.each do |from, to|
      source_dir      = File.join(config.root, from)
      destination_dir = File.join(directive.build_dir, to)
      
      FileUtils.mkdir_p(destination_dir)

      FileUtils.cp_r(source_dir, destination_dir, preserve: true)
    end
  end
end