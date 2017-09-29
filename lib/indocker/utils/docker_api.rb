class Indocker::DockerApi
  include SmartIoC::Iocify

  bean :docker_api

  def find_image_by_repo(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    all_images.detect do |image|
      image.info['RepoTags'].include?(full_name(repo, tag))
    end
  end

  def image_exists_by_repo?(repo, tag: Indocker::ImageMetadata::DEFAULT_TAG)
    !find_image_by_repo(repo, tag: tag).nil?
  end

  def create_container(container_metadata)
    Docker::Container.create('Image' => container_metadata.from_image, 'name' => container_metadata.name)
  end

  def build_from_dir(image_metadata, skip_tag: false, skip_push: false)
    image = Docker::Image.build_from_dir(image_metadata.build_dir)

    image.tag(
      repo:  image_metadata.repo, 
      tag:   image_metadata.tag, 
      force: true
    ) unless skip_tag

    image
  end

  def pull(opts)
    Docker::Image.create(opts)
  end

  def all_images
    Docker::Image.all
  end

  def full_name(repo, tag)
    "#{repo}:#{tag}"
  end

  def find_container_by_name(name)
    all_containers.detect do |container|
      container.info['Names'].include?("/#{name}")
    end
  end

  def find_container_by_id(id)
    all_containers.detect do |container|
      container.id == id
    end
  end

  def container_exists_by_name?(name)
    !find_container_by_name(name).nil?
  end

  def all_containers
    Docker::Container.all(:all => true)
  end
end