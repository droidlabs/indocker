Indocker.define_image 'sample_package' do
  before_build do
    docker_cp 'assets_compiler' do
      copy 'assets' => 'assets'
    end
  end

  from 'ubuntu'

  run        'mkdir /app'
  workdir    'app'
  entrypoint 'ls > ls.txt'

  cmd        'pwd'
end

Indocker.define_container 'assets_compiler' do
  use images.assets_compiler
end

Indocker.define_image 'assets_compiler' do
  from 'ubuntu'

  copy 'assets/.', '/assets'
end