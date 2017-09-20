class Indocker::DockerCommands
  include SmartIoC::Iocify
  
  BUILD_IMAGE_ID = /Successfully built ([\w\d]{12})/
  RUN_CONTAINER_ID = /([\w\d]{64})/
  
  bean   :docker_commands
  inject :shell_commands


  # def image_exists?(image_name)
  #   get_image_id(image_name) != ""
  # end

  # def get_image_id(image_name)
  #   command = "docker images -q #{image_name}"

  #   shell_commands.run_command_with_result(command) do |result|
  #     return result.to_s.strip
  #   end
  # end

  # def build_image(image_name)
  #   command = "docker build --rm=true -t #{image_name} ."

  #   shell_commands.run_command_with_result(command, with_sudo: true) do |result|
  #     return BUILD_IMAGE_ID.match(result).captures.first
  #   end
  # end

  # def container_exists?(container_name)
  #   get_container_id(container_name) != ""
  # end

  # def get_container_id(container_name)
  #   command = "docker inspect --format='{{.Id}}' #{container_name}"

  #   shell_commands.run_command_with_result(command) do |result|
  #     return result.to_s.strip
  #   end
  # end

  # def run_container(container_name, image_name)
  #   command = "docker run --name=#{container_name} --rm -d #{image_name}"
    
  #   shell_commands.run_command_with_result(command, with_sudo: true) do |result|
  #     return RUN_CONTAINER_ID.match(result).captures.first
  #   end
  # end

  # def remove_images_by_mask(mask)
  #   command = "docker rmi $(docker images | awk '{print $1,$3}' | grep '#{mask}' | awk '{print $2}') --force"
  #   shell_commands.run_command(command)
  # end
end