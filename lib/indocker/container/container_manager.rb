class Indocker::ContainerManager
  KEEP_CONTAINER_RUNNING_COMMAND = %w(tail -F -n0 /etc/hosts)

  include SmartIoC::Iocify
  
  bean   :container_manager

  inject :container_metadata_repository
  inject :image_metadata_repository
  inject :container_directives_runner
  inject :docker_api
  inject :logger
  inject :tar_helper
  inject :config
  inject :envs_loader

  def create(name)
    container_metadata = container_metadata_repository.get_by_name(name)

    env_metadata = container_metadata.env_files
      .map {|path| envs_loader.parse(config.root.join(path))}
      .inject(Indocker::Envs::EnvMetadata.new) {|sum, env| sum += env}
    
    container_id = docker_api.create_container(
      name:          name, 
      repo:          container_metadata.repo, 
      tag:           container_metadata.tag,
      exposed_ports: container_metadata.exposed_ports,
      port_bindings: container_metadata.port_bindings,
      env:           env_metadata.to_array
    )

    logger.info "Successfully created container :#{name}"

    container_id
  end

  def start(name)
    container_metadata = container_metadata_repository.get_by_name(name)
    
    container_directives_runner.run_all(
      container_metadata.before_start_directives
    )

    container_metadata.container_dependencies.each do |dependency|
      create(dependency) unless docker_api.container_exists?(dependency)
      
      unless docker_api.get_container_state(dependency) == Indocker::ContainerMetadata::States::RUNNING
        start(dependency)  
      end
    end

    container_id = docker_api.start_container(name)

    logger.info "Successfully started container :#{name}"
    
    container_directives_runner.run_all(
      container_metadata.after_start_directives
    )

    container_id
  rescue Docker::Error::ClientError => e
    logger.error "The following error occured when starting :#{name} container"
    logger.error e.message
  end

  def stop(name)
    container_id = docker_api.stop_container(name)

    logger.info "Successfully stopped container :#{name}"

    container_id
  end

  def delete(name)
    container_id = docker_api.delete_container(name)

    logger.info "Successfully deleted container :#{name}"

    container_id
  end

  def copy(name:, copy_from:, copy_to:)
    container_metadata = container_metadata_repository.get_by_name(name)
    
    container_id = docker_api.create_container(
      repo:    container_metadata.repo, 
      tag:     container_metadata.tag,
      command: KEEP_CONTAINER_RUNNING_COMMAND
    ) if !docker_api.container_exists?(name)
      
    tar_snapshot    = File.join(config.root, 'tmp', "#{name.to_s}.tar")

    docker_api.copy_from_container(name: container_id, path: copy_from) do |tar_archive|
      File.open(tar_snapshot, 'w') {|f| f.write(tar_archive)}
    end
    
    files_list = tar_helper.untar(
      io:                    File.open(tar_snapshot, 'r'),
      destination:           copy_to,
      ignore_wrap_directory: File.basename(copy_from) == '.'
    )

    FileUtils.rm_rf(tar_snapshot)
    
    docker_api.stop_container(container_id)
    docker_api.delete_container(container_id)

    files_list
  end
end