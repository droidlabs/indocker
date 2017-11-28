class Indocker::ImageDirectivesRunner
  include SmartIoC::Iocify

  bean :image_directives_runner

  inject :container_manager
  inject :config
  inject :render_util
  inject :docker_api

  def run_all(directives)
    directives.each {|c| run(c)}
  end

  def run(directive)
    case directive
    when Indocker::ImageDirectives::DockerCp
      run_docker_cp(directive)
    when Indocker::ImageDirectives::Copy
      run_copy(directive)
    when Indocker::ImageDirectives::Registry
      run_registry(directive)
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
      copy_compile_file(
        from:    from,
        to:      File.join(directive.build_dir, from),
        locals:  directive.locals,
        compile: directive.compile
      )
    end
  end

  def run_registry(directive)
    docker_api.tag(
      repo:     directive.repo, 
      tag:      directive.tag,
      new_repo: directive.new_repo,
      new_tag:  directive.new_tag
    )
    
    docker_api.push(
      repo:         directive.repo, 
      tag:          directive.tag,
      push_to_repo: directive.new_repo,
      push_to_tag:  directive.new_tag
    ) if directive.push
  end

  private

  def copy_compile_file(from:, to:, locals: {}, compile: false)
    raise ArgumentError, "Copy destination #{from} not exists" if !File.exists?(from)

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