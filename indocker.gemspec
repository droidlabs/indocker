require_relative 'lib/indocker/version'

Gem::Specification.new do |s|
  s.name        = 'indocker'
  s.version     = Indocker::VERSION
  s.summary     = "Indocker"
  s.description = "DSL for build, run and deploy docker containers"
  s.authors     = ["Droid Labs"]
  s.email       = 'hello@droidlabs.pro'
  
  s.files       = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(spec)/})

  s.add_development_dependency "byebug"
  s.add_development_dependency "rspec"
  
  s.add_dependency "smart_ioc"
  s.add_dependency "docker-api"
  s.add_dependency "docker_registry2"
  s.add_dependency "thor"
  s.add_dependency "colorize"
  s.add_dependency "git"
  s.add_dependency "dto"
  s.add_dependency "byebug" # TODO: remove after release

  s.homepage    = 'https://github.com/droidlabs/indocker'
  s.license     = 'MIT'
end