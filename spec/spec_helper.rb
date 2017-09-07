$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(__dir__)

require 'indocker'
require 'fileutils'
require 'byebug'

SmartIoC.find_package_beans(:indocker, File.expand_path('../lib', __dir__))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

