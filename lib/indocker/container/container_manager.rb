class Indocker::ContainerManager
  KEEP_CONTAINER_RUNNING_COMMAND = %w(tail -F -n0 /etc/hosts)

  include SmartIoC::Iocify
  
  bean :container_manager

  inject :container_metadata_repository
  inject :image_metadata_repository
  inject :container_directives_runner
  inject :docker_api
  inject :logger
  inject :tar_helper
  inject :config
  inject :container_builder

  def create(name)
    container_config = container_builder.build(name)
    
    container_id = docker_api.create_container(container_config)

    logger.info "Successfully created container :#{name}"

    container_id
  end

  def run(name)
    container_metadata = container_metadata_repository.find_by_name(name)

    container_image_id = docker_api.get_container_image_id(name)
    image_id           = docker_api.get_image_id(container_metadata.repo, tag: container_metadata.tag)

    raise Indocker::Errors::ImageIsNotBuilded, container_metadata.image if image_id.nil?

    if docker_api.container_exists?(name)
      if image_id != container_image_id
        stop(name)
        delete(name)
        create(name) 
      end
    else
      create(name)
    end

    stop(name)
    start(name, attach: container_metadata.attach)
  end

  def start(name, attach: false)
    container_metadata = container_metadata_repository.find_by_name(name)
    
    container_directives_runner.run_all(
      container_metadata.before_start_directives
    )

    container_metadata.container_dependencies.each do |dependency|
      dependency_metadata = container_metadata_repository.find_by_name(dependency)
      create(dependency) unless docker_api.container_exists?(dependency)
      
      if docker_api.get_container_state(dependency) == Indocker::ContainerMetadata::States::RUNNING
        logger.info "Dependency container :#{dependency} already running"
      else
        start(dependency, attach: dependency_metadata.attach)  
      end
    end

    container_id = docker_api.start_container(name, attach: attach)

    logger.info "Successfully started container :#{name}"
    
    container_directives_runner.run_all(
      container_metadata.after_start_directives
    )

    container_id
  end

  def stop(name)
    container_id = docker_api.stop_container(name)

    logger.info "Successfully stopped container :#{name}"

    container_id
  end

  def delete(name)
    stop(name)

    container_id = docker_api.delete_container(name)

    logger.info "Successfully deleted container :#{name}"

    container_id
  end

  def copy(name:, copy_from:, copy_to:)
    container_metadata = container_metadata_repository.find_by_name(name)

    container_id =  docker_api.get_container_id(name) ||
                    docker_api.create_container(container_builder.build(name))
      
    tar_snapshot = config.build_dir.join('snapshots', "#{name.to_s}.tar")
    
    FileUtils.mkdir_p(File.dirname(tar_snapshot))
    docker_api.copy_from_container(name: container_id, path: copy_from) do |tar_archive|
      File.open(tar_snapshot, 'a+') {|f| f.write(tar_archive)}
    end

    files_list = []
    tar_helper.untar(tar_snapshot, to: copy_to) do |filename|
      files_list.push(filename)
    end

    FileUtils.rm_rf(tar_snapshot)
    
    docker_api.stop_container(container_id)
    docker_api.delete_container(container_id)

    files_list
  end
end