require_relative 'strategy.rb'
require 'fileutils.rb'

class Pull < Strategy

  def use
    raise "The method 'use' was called from base class"
  end

  protected
  
  def clean_if_exist(directory)
    FileUtils.rm_rf(File.expand_path(directory)) if directory
  end

end