$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(__dir__)

require 'indocker'
require 'fileutils'
require 'byebug'

SmartIoC::Container.get_instance.set_extra_context_for_package(:indocker, :test)
SmartIoC.set_load_proc do |location|
  require(location)
end

Indocker.root(Pathname.new File.expand_path(File.join(__dir__, 'example')))
Indocker.build_dir(Pathname.new File.expand_path(File.join(__dir__, '../tmp/build')))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.after(:each) do
    ioc.docker_api.delete_containers_where { |container| container.refresh!.info['Config']['Image'] =~ /^indocker/ }
    ioc.docker_api.delete_containers_where { |container| container.refresh!.info['Names'].grep(/^\/indocker/).any? }
    ioc.docker_api.delete_images_where     { |image|     image.info['RepoTags'].grep(/^indocker/).any? }
    ioc.docker_api.delete_networks_where   { |network|   network.info['Name'] =~ /^indocker/ }

    ioc.image_metadata_repository.clear
    ioc.container_metadata_repository.clear
    ioc.partial_metadata_repository.clear
    ioc.network_metadata_repository.clear

    ioc.logger.clear

    FileUtils.rm_rf(Dir.glob(File.join(__dir__, '../tmp/*')))
  end
end

def ensure_exists(file)
  expect(File.exists?(file)).to be true
end

def ensure_content(file, content)
  expect(File.read(file)).to match(content)
end