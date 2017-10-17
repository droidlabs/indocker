class Indocker::DockerApi
  include SmartIoC::Iocify

  bean :docker_api

  inject :logger

  def check_docker_installed!
    Docker.info
    nil
  rescue Excon::Error::Socket
    raise Indocker::Errors::DockerDoesNotInstalled
  end

  def authenticate!(serveraddress:, email:, password:, username:)
    params = {
      'serveraddress' => serveraddress,
      'email'         => email,
      'password'      => password,
      'username'      => username
    }.delete_if {|_, value| value.to_s.empty?}

    Docker.authenticate!(params)
  end

  # Images

  def get_image_id(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    Docker::Image.get(full_name(repo, tag)).id
  end

  def image_exists?(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    Docker::Image.exist?(full_name(repo, tag))
  end

  def delete_image(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    Docker::Image.get(full_name(repo, tag)).remove(force: true)
  end

  def build_from_dir(repo:, tag:, build_dir:)
    image = Docker::Image.build_from_dir(build_dir) do |x|
      x.split("\r\n").each do |y|
        if (log = JSON.parse(y)) && log.has_key?("stream")
          yield log["stream"].strip
        end
      end
    end

    image.tag(
      repo:  repo, 
      tag:   tag, 
      force: true
    )

    image.id
  end

  def pull(opts)
    image = Docker::Image.create(opts)

    image.id
  end

  def delete_images_where(&condition)
    Docker::Image.all.select(&condition).map do |image|
      image.remove(force: true)
    end
  end


  # Containers

  def get_container_id(name)
    Docker::Container.get(name.to_s).id
  end

  def get_container_state(name)
    Docker::Container.get(name.to_s).info["State"]["Status"]
  end

  def container_exists?(name)
    !Docker::Container.get(name.to_s).nil? rescue false
  end

  def start_container(name)
    Docker::Container.get(name.to_s).start!.id
  end

  def stop_container(name)
    Docker::Container.get(name.to_s).stop
  end

  def copy_from_container(name:, path:)
    Docker::Container.get(name.to_s).copy(path) { |chunk| yield chunk }
  end

  def create_container(repo:, tag:, name: nil, command: nil)
    params = {
      'Image' => full_name(repo, tag), 
      'name'  => name.to_s,
      'Cmd'   => command
    }.delete_if { |_, value| value.to_s.empty? }

    Docker::Container.create(params).id
  end

  def exec_container(name:, command:)
    Docker::Container.get(name.to_s).exec(command) do |stream, chunk|
      yield stream, chunk
    end
  end

  def delete_container(name)
    Docker::Container.get(name.to_s).delete(:force => true)
  end

  def delete_containers_where(&condition)
    Docker::Container.all(all: true).select(&condition).map do |container|
      container.stop
      container.delete(force: true)
    end
  end

  def container_run(repo:, tag:, command:)
    container = Docker::Container.create(
      'Image'        => full_name(repo, tag), 
      'Cmd'          => command
    ).id
  end

  private

  def full_name(repo, tag)
    "#{repo.to_s}:#{tag.to_s}"
  end
end