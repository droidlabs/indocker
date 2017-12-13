require 'docker-api'
require 'io/console'

Docker.options = { read_timeout: 600, write_timeout: 600, chunk_size: 1 }

class Indocker::DockerAPI
  include SmartIoC::Iocify
  include Indocker::ImageHelper

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

  # Networks

  def create_network(name)
    Docker::Network.create(name.to_s).id
  end

  def add_container_to_network(network_name:, container_name:)
    container_id = get_container_id(container_name.to_s)

    Docker::Network.get(network_name.to_s).connect(container_id.to_s)
  end

  def delete_network(name)
    Docker::Network.get(name.to_s).remove
  end

  def network_exists?(name)
    !Docker::Network.get(name.to_s).nil? rescue false
  end

  def get_network_id(name)
    Docker::Network.get(name.to_s).id
  end

  def inspect_network(name)
    Docker::Network.get(name.to_s).info
  end

  def delete_networks_where(&condition)
    Docker::Network.all.select(&condition).map do |network|
      network.remove
    end
  end

  # Images

  def get_image_id(repo, tag: nil)
    Docker::Image.get(full_name(repo, tag)).id rescue nil
  end

  def image_exists?(repo, tag: nil)
    Docker::Image.exist?(full_name(repo, tag))
  end

  def delete_image(repo, tag: nil)
    Docker::Image.get(full_name(repo, tag)).remove(force: true)
  end

  def build_from_dir(repo:, tag:, build_dir:)
    image = Docker::Image.build_from_dir(build_dir, { 't' => "#{repo}:#{tag}" }) do |x|
      yield x
      # x.split("\r\n").each do |y|
      #   if (log = JSON.parse(y)) && log.has_key?("stream")
      #     yield log["stream"].strip
      #   end
      # end
    end

    image.id
  end

  def tag(repo:, tag: nil, new_repo:, new_tag:)
    Docker::Image.get(full_name(repo, tag)).tag('repo' => new_repo, 'tag' => new_tag)

    nil
  end

  def push(repo:, tag:, push_to_repo:, push_to_tag:)
    Docker::Image.get(full_name(repo, tag)).push(nil, repo_tag: full_name(push_to_repo, push_to_tag))

    nil
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

  #Volumes

  def create_volume(name)
    Docker::Volume.create(name.to_s).id
  end

  def get_volume_id(name)
    Docker::Volume.get(name.to_s).id
  end

  def all_volumes(name)
    Docker::Volume.all
  end

  def delete_volume(name)
    Docker::Volume.get(name.to_s).remove
  end

  def volume_exists?(name)
    !Docker::Volume.get(name.to_s).nil? rescue false
  end

  def inspect_volume(name)
    Docker::Volume.get(name.to_s).info
  end

  def delete_volumes_where(&condition)
    Docker::Volume.all.select(&condition).map do |volume|
      volume.remove
    end
  end

  # Containers

  def inspect_container(name)
    Docker::Container.get(name.to_s).info
  end

  def get_container_id(name)
    Docker::Container.get(name.to_s).id rescue nil
  end

  def get_container_image_id(name)
    Docker::Container.get(name.to_s).info['Image'] rescue nil
  end

  def get_container_state(name)
    Docker::Container.get(name.to_s).info["State"]["Status"]
  end

  def container_exists?(name)
    !Docker::Container.get(name.to_s).nil? rescue false
  end

  def start_container(name, attach: false)
    container = Docker::Container.get(name.to_s).start!

    if attach
      STDIN.raw do |stdin| 
        container.attach(stdin: stdin, tty: true) do |chunk|
          logger << chunk
        end
      end
    end

    container.id
  end

  def stop_container(name)
    Docker::Container.get(name.to_s).stop rescue nil
  end

  def copy_from_container(name:, path:, &block)
    Docker::Container.get(name.to_s).copy(path, &block)
  end

  # TODO: Add contract
  def create_container(container_config)
    Docker::Container.create(container_config.to_hash).id
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
end