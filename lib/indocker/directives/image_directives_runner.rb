class Indocker::ImageDirectivesRunner
  include SmartIoC::Iocify

  bean :image_directives_runner

  inject :container_manager
  inject :config
  inject :render_util

  def run_all(directives)
    directives.each {|c| run(c)}
  end

  def run(directive)
    case directive
    when Indocker::PrepareDirectives::DockerCp
      run_docker_cp(directive)
    when Indocker::DockerDirectives::Copy
      run_copy(directive)
    else
      # do nothing
    end
  end

  def run_docker_cp(directive)
    directive.copy_actions.each do |from, to|
      container_manager.copy(
        name:      directive.container_name,
        copy_from: from,
        copy_to:   to
      )
    end
  end

  def run_copy(directive)
    directive.copy_actions.each do |from, to|
      build_dir_file = File.join(directive.context.build_dir, from)

      source_dir = File.join(config.root, from)
      
      if File.directory?(from)
        dest_dir = File.join(directive.context.build_dir, from)
      else
        dest_dir = File.join(directive.context.build_dir, File.dirname(from))
      end

      if File.exists?(build_dir_file) && File.file?(build_dir_file)
        copy_compile_file(
          from:    build_dir_file, 
          to:      build_dir_file, 
          locals:  directive.context.storage, 
          compile: directive.compile
        )

        return
      end
      
      if File.exist?(build_dir_file) && File.directory?(build_dir_file)
        files_list = Dir.glob(File.join(build_dir_file, '**', '*'), File::FNM_DOTMATCH)

        files_list.each do |from|
          copy_compile_file(
            from:    from, 
            to:      from, 
            locals:  directive.context.storage, 
            compile: directive.compile
          )
        end

        return
      end

      if File.exists?(source_dir) && File.file?(source_dir)
        copy_compile_file(
          from:    source_dir, 
          to:      File.join(dest_dir, File.basename(source_dir)), 
          locals:  directive.context.storage, 
          compile: directive.compile
        )

        return
      end

      if Dir.exist?(source_dir) && File.directory?(source_dir)
        files_list = Dir.glob(File.join(source_dir, '**', '*'), File::FNM_DOTMATCH)

        files_list.each do |from|
          relative_to = Pathname.new(from).relative_path_from( Pathname.new(source_dir) ).to_s
          absolute_to = File.join(dest_dir, relative_to)

          copy_compile_file(
            from:    from, 
            to:      absolute_to, 
            locals:  directive.context.storage, 
            compile: directive.compile
          )
        end

        return
      end

      raise Indocker::Errors::FileDoesNotExists
    end
  end

  private

  def copy_compile_file(from:, to:, locals: {}, compile: false)
    return if !File.exists?(from) || File.directory?(from)
    
    FileUtils.mkdir_p(File.dirname(to)) unless Dir.exist?(File.dirname(to))

    write_content = compile ? render_util.render( File.read(from), locals ) : 
                              File.read(from)

    File.write(to, write_content)

    File.chmod(File.stat(from).mode, to)
  end
end