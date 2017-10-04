class Indocker::DirectivesRunner
  include SmartIoC::Iocify

  bean   :directives_runner
  inject :container_runner

  def run_all(commands)
    commands.each {|c| run(c)}
  end

  def run(command)
    case command
    when Indocker::PrepareDirectives::DockerCp
      run_docker_cp(command)
    when Indocker::PrepareDirectives::Copy
      run_copy(command)
    end
  end

  def run_docker_cp(command)
    container = container_runner.create(command.container_name)

    command.copy_actions.each do |copy_action|
      File.open(File.join(command.build_dir, copy_action[:to]), 'w') do |f|
        container.copy(copy_action[:from]) { |chunk| f.write(chunk) }
      end
    end
  end

  def run_copy(command)
    command.copy_actions.each do |copy_action|
      FileUtils.cp_r(
        File.join(Indocker.root, copy_action[:from]), 
        File.join(command.build_dir, copy_action[:to]), 
        preserve: true
      )
    end
  end
end