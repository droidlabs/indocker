class Indocker::FileUtils
  include SmartIoC::Iocify

  bean :file_utils

  inject :logger

  def cp_r_with_modify(from:, to:, &modify_block)
    selected_files = files_list(from)

    case selected_files.size
    when 0
      logger.warn "No files were copied!" if selected_files.empty?
    when 1
      source_filename = selected_files.first
      destination_filename = is_file_name?(to) || File.file?(to) ? to : File.join(to, File.basename(source_filename))

      copy_entry_with_modify(source_filename, destination_filename, &modify_block)
    else
      selected_files.each do |filename|
        destination_filename = File.join(to, relative_path(from: real_parent_dir(from), to: filename))
        
        copy_entry_with_modify(filename, destination_filename, &modify_block)
      end
    end
  end

  def copy_entry_with_modify(from, to)
    to_file = is_file_name?(to) ? to : File.join(to, File.basename(from))
    FileUtils.mkdir_p File.dirname(to_file)

    tempfile = Tempfile.new

    FileUtils.copy_file(from, tempfile.path, preserve: true)

    yield tempfile if block_given?

    FileUtils.copy_file(tempfile.path, to_file, preserve: true)
  end

  def within_temporary_directory(directory_path, &block)
    FileUtils.mkdir_p(directory_path)

    FileUtils.cd(directory_path) do
      block.call
    end
  ensure
    FileUtils.rm_rf(directory_path)
  end

  private

  def is_file_name?(filename)
    !is_directory_content?(filename) && !File.extname(filename).empty?
  end

  def is_directory_name?(filename)
    !is_directory_content?(filename) && File.extname(filename).empty?
  end

  def is_directory_content?(filename)
    File.basename(filename) == '.'
  end

  def relative_path(from:, to:)
    from_path = Pathname.new(from)
    to_path   = Pathname.new(to)

    to_path.relative_path_from(from_path).to_s
  end

  def files_list(path)
    glob_path = File.directory?(path) ? File.join(path, '**/*') : path

    Dir.glob(glob_path, File::FNM_DOTMATCH).select {|f| File.file?(f)}
  end

  def real_parent_dir(path)
    File.directory?(path) ? path : real_parent_dir(File.dirname(path))
  end
end