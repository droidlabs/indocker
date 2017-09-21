$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(__dir__)

require 'indocker'
require 'fileutils'
require 'byebug'

SmartIoC::Container.get_instance.set_extra_context_for_package(:indocker, :test)
SmartIoC.set_load_proc do |location|
  require(location)
end

Indocker.root(File.expand_path(File.join(__dir__, '../tmp')))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.after(:each) do
    ioc.docker_api.all_containers.each do |container|
      container.delete(force: true) if container.info['Image'].match(/^indocker/)
    end

    ioc.docker_api.all_images.each do |image|
      image.remove(force: true) if image.info['RepoTags'].find {|rt| rt =~ /^indocker/}
    end

    Indocker.images.clear
    Indocker.containers.clear
  end
end



