class Indocker::DirectivesRunner
  include SmartIoC::Iocify

  bean   :directives_runner
  inject :container_manager

  def run_all(directives)
    directives.each {|c| run(c)}
  end

  def run(directive)
    case directive
    when Indocker::PrepareDirectives::DockerCp
      run_docker_cp(directive)
    when Indocker::PrepareDirectives::Copy
      run_copy(directive)
    end
  end

  def run_docker_cp(directive)
    directive.copy_actions.each do |copy_action|
      container_manager.copy(
        name: directive.container_name,
        copy_from: copy_action[:from],
        copy_to:   copy_action[:to]
      )
    end
  end

  def run_copy(directive)
    directive.copy_actions.each do |copy_action|
      FileUtils.cp_r(
        File.join(Indocker.root, copy_action[:from]), 
        File.join(directive.build_dir, copy_action[:to]), 
        preserve: true
      )
    end
  end
end