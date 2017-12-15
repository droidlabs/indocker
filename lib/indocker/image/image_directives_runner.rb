class Indocker::ImageDirectivesRunner
  include SmartIoC::Iocify

  bean :image_directives_runner

  inject :container_manager
  inject :config
  inject :render_util
  inject :file_utils
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
        copy_to:   to
      )
    end
  end

  def run_copy(directive)
    directive.copy_actions.each do |copy|
      modify_block = directive.compile ? Proc.new do |tempfile|
        template_content = File.read(tempfile.path)
        compiled_content = render_util.render(template_content, directive.locals)

        File.write(tempfile.path, compiled_content)
      end : nil

      file_utils.cp_r_with_modify(from: copy.from, to: File.join(directive.build_dir.to_s, copy.to), &modify_block)
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
end