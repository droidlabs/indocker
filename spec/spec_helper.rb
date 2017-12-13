$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(__dir__)

require 'indocker'
require 'fileutils'
require 'byebug'

SmartIoC::Container.get_instance.set_extra_context_for_package(:indocker, :test)
SmartIoC.set_load_proc do |location|
  require(location)
end

ioc.config.build_dir      File.expand_path(File.join(__dir__, '../tmp/build'))
ioc.config.template_dir   File.expand_path(File.join(__dir__, 'fixtures'))
ioc.config.git.cache_dir  File.expand_path(File.join(__dir__, '../tmp/cache'))

ioc.config.docker.registry(:localhost) { serveraddress 'http://localhost:1000' }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.after(:all) { truncate_docker_items }
end

def ensure_exists(file)
  expect(File.exists?(file)).to be true
end

def ensure_content(file, content)
  expect(File.read(file)).to match(content)
end

def truncate_docker_items
  ioc.docker_api.delete_containers_where { |container| container.refresh!.info['Config']['Image'] =~ /^indocker/ }
  ioc.docker_api.delete_containers_where { |container| container.refresh!.info['Names'].grep(/^\/indocker/).any? }
  ioc.docker_api.delete_images_where     { |image|     image.info['RepoTags'] && image.info['RepoTags'].grep(/^indocker/).any? }
  ioc.docker_api.delete_networks_where   { |network|   network.info['Name'] =~ /^indocker/ }
  ioc.docker_api.delete_volumes_where    { |volume|    volume.info['Name'] =~ /^indocker/ }

  ioc.image_metadata_repository.clear
  ioc.container_metadata_repository.clear
  ioc.partial_metadata_repository.clear
  ioc.network_metadata_repository.clear
  ioc.volume_metadata_repository.clear

  ioc.logger.clear
    
  FileUtils.rm_rf(Dir.glob(File.join(__dir__, '../tmp/*')))
end

def set_local_registry
  Indocker.define_image :registry do
    from 'registry:latest'
  end
  
  Indocker.define_container :indocker_registry do
    use images.find_by_repo(:registry)
    env 'REGISTRY_STORAGE_DELETE_ENABLED=true'
    ports '5000:1000'
  end
  
  ioc.image_builder.build('registry')
  ioc.container_manager.run('indocker_registry')
end