class Indocker::ShellCommands
  include SmartIoC::Iocify
  
  bean :shell_commands
  
  def run_command(command, with_sudo: false, &block)
    if $use_sudo && with_sudo
      command = "sudo #{command}"
    end

    Indocker.logger.info(command)

    system(command, out: $stdout, err: :out)

    exit 1 if !$?.success?

    if block_given?
      yield
    end
  end

  def run_command_with_result(command, with_sudo: false, &block)
    if $use_sudo && with_sudo
      command = "sudo #{command}"
    end

    Indocker.logger.info(command)

    IO.popen(command, err: [:child, :out]) do |io|
      result = io.read
      Indocker.logger.debug(result)

      if block_given?
        yield result
      end
    end
  end
end