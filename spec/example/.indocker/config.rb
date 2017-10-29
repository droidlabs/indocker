Idocker.setup do
  namespace     'indocker_example'
  root          Pathname.new File.dirname(__dir__)
  cache_dir     Pathname.new '/tmp/indocker'

  load_env_file '.indocker/env_files'
  load_docker_items [
    '.indocker/images_and_containers.rb'
  ]

  git do
    repository 'https://github.com/droidlabs/indocker'
    tag        'latest'
    branch     'master'
    workdir    'some/path'
  end
  
  docker do
    registry   'localhost:5000'
    skip_push  true
  end

  build_server :build_server
end