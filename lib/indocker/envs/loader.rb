class Indocker::Envs::Loader
  include SmartIoC::Iocify

  bean :envs_loader

  def parse(path)
    raise Indocker::Errors::EnvFileDoesNotExist if !File.exists?(path)

    env_metadata = Indocker::Envs::EnvMetadata.new

    File.foreach(path) do |line|
      key, value = line.split('=').map(&:strip)

      env_metadata.set(key: key, value: value)
    end

    env_metadata
  end
end