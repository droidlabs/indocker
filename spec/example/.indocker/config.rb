Idocker.setup do
  namespace 'indocker_example'

  load_env_file '.indocker/env_files'
  load_docker_items [
    '.indocker/images_and_containers.rb'
  ]

  docker do
    registry :indocker do
      serveraddress: 'localhost:1000'
    end
  end

  git do
    cache_dir '/tmp/indocker'

    repo :indocker do
      repository 'https://github.com/droidlabs/indocker'
      branch     'master'
    end
  end
  
  docker do
    registry   'localhost:1000'
    skip_push  true
  end

  build_server :build_server
end