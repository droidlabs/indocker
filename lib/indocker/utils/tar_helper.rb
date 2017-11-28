require 'fileutils'

class Indocker::TarHelper
  include SmartIoC::Iocify

  bean :tar_helper

  inject :shell_util

  def untar(tarfile, to: nil, strip_component: 0, &block)
    FileUtils.mkdir_p(to) if !to.nil?
    to_option = to.nil? ? '' : "-C #{to} --strip-components=#{strip_component}"
    
    command = "tar -xvf #{tarfile} #{to_option}"

    shell_util.run_command_with_result(command, &block)
  end
end