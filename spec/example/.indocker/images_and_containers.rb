Indocker.define_image 'sample_package' do
  before_build do
    extract 'assets_compiler', from: 'assets', to: 'assets'
  end

  from 'ubuntu'

  run 'mkdir /app'
  workdir 'app'
  entrypoint 'ls > ls.txt'

  cmd 'pwd'
end

Indocker.container 'assets_compiler' do
  from 'assets_compiler'
end

Indocker.define_image 'assets_compiler' do
  from 'ubuntu'

  copy 'assets', 'assets'
end