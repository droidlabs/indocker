class Indocker::DirectivesRunner
  include SmartIoC::Iocify

  bean   :directives_runner
  inject :container_runner

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
    container = container_runner.create(directive.container_name)

    directive.copy_actions.each do |copy_action|
      File.open(File.join(directive.build_dir, copy_action[:to]), 'w') do |f|
        container.copy(copy_action[:from]) { |chunk| f.write(chunk) }
      end
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