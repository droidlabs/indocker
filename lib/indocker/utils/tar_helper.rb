require 'rubygems'
require 'rubygems/package'
require 'zlib'
require 'fileutils'

class Indocker::TarHelper
  include SmartIoC::Iocify

  bean :tar_helper

  def untar(io:, destination:, ignore_wrap_directory: false)
    files_list = []

    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        if ignore_wrap_directory
          tarfile_full_name = tarfile.full_name.split('/')[1..-1].join('/')
        else 
          tarfile_full_name = tarfile.full_name
        end

        destination_file = File.join(destination, tarfile_full_name)
        
        if tarfile.directory?
          FileUtils.mkdir_p destination_file
        else
          files_list.push(tarfile_full_name)

          if !File.directory?(destination)
            FileUtils.mkdir_p destination 
          end

          File.open(destination_file, "wb") {|f| f.print tarfile.read}
        end
      end
    end

    files_list
  end
end