require 'fileutils'

class Indocker::TarHelper
  include SmartIoC::Iocify

  bean :tar_helper

  inject :shell_util

  def untar(tarfile, to: nil, &block)
    FileUtils.mkdir_p(to) if !to.nil?
    to_option = to.nil? ? '' : "-C #{to} --strip-components=1"
    
    command = "tar -xvf #{tarfile} #{to_option}"

    shell_util.run_command_with_result(command, &block)
  end
end