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
    end
  end

  def run_docker_cp(directive)
    directive.copy_actions.each do |from, to|
      container_manager.copy(
        name:      directive.container_name,
        copy_from: from,
        copy_to:   File.join(directive.build_dir, to)
      )
    end
  end

  def run_copy(directive)
    directive.copy_actions.each do |from, _|
      source      = File.exists?(from) ? from : File.join(directive.build_dir, from)
      destination = File.join(directive.build_dir.to_s, from.to_s)

      copy_compile_file(
        from:    source, 
        to:      destination, 
        locals:  directive.locals, 
        compile: directive.compile
      )
    end
  end

  private
  
  def copy_compile_file(from:, to:, locals: {}, compile: false)
    if File.directory?(from)
      Dir.glob(File.join(from, '**', '*'), File::FNM_DOTMATCH).each do |file_source_path|
        next if File.directory?(file_source_path)

        file_relative_path = Pathname.new(file_source_path).relative_path_from( Pathname.new(from) ).to_s
        file_destination_path = File.join(to, file_relative_path)
      
        copy_compile_file(
          from:    file_source_path, 
          to:      file_destination_path,
          locals:  locals,
          compile: compile
        )
      end

      return
    end

    if !Dir.exist?(File.dirname(to))
      FileUtils.mkdir_p(File.dirname(to)) 
    end
    
    write_content = compile ? render_util.render( File.read(from), locals ) : 
                              File.read(from)
    File.write(to, write_content)
    
    File.chmod(File.stat(from).mode, to)
  end
end