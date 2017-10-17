class Indocker::Configs::Locator
  include SmartIoC::Iocify

  bean :config_locator

  ROOT = '/'

  def locate(path)
    expand_path = potential_config_file File.expand_path(path)
    
    return expand_path if File.exists?(expand_path)
    
    raise Indocker::Errors::ConfigFilesDoesNotFound if path == ROOT

    locate(File.dirname(path))
  end

  private

  def potential_config_file(path)
    File.join(path, '.indocker', 'config.rb')
  end
end