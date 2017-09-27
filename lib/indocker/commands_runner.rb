class Indocker::CommandsRunner
  include SmartIoC::Iocify

  bean :commands_runner

  def run_all(*commands)
    commands.each {|c| run(c)}
  end

  def run(command)
    # some stuff
  end
end