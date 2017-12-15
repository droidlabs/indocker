class Indocker::FileUtils
  include SmartIoC::Iocify

  bean :file_utils

  inject :logger

  def cp_r_with_modify(from:, to:, &modify_block)
    created_files = []

    if File.file?(from) && !File.directory?(to) && is_file_name?(to)
      created_files << copy_entry_with_modify(from, to, &modify_block) 
      return created_files
    end
    
    files_list(from).each do |file|
      base_dir = real_parent_dir(from)
      base_dir = File.dirname(base_dir) if File.directory?(from) && !is_directory_content?(from)
      
      dest_path = File.join(to, relative_path(from: base_dir, to: file))
      
      copy_entry_with_modify(file, dest_path, &modify_block)

      created_files.push(dest_path)
    end

    logger.warn "No files were copied!" if created_files.empty?

    created_files
  end

  def copy_entry_with_modify(from, to)
    FileUtils.mkdir_p File.dirname(to)

    tempfile = Tempfile.new

    FileUtils.copy_file(from, tempfile.path, preserve: true)

    yield tempfile if block_given?

    FileUtils.copy_file(tempfile.path, to, preserve: true)
  end

  def within_temporary_directory(directory_path, &block)
    FileUtils.mkdir_p(directory_path)

    FileUtils.cd(directory_path) do
      block.call
    end
  ensure
    FileUtils.rm_rf(directory_path)
  end

  def real_parent_dir(path)
    File.directory?(path) ? path : real_parent_dir(File.dirname(path))
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
end