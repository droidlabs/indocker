class Indocker::DockerCommands
  BUILD_IMAGE_ID = /Successfully built ([\w\d]{12})/

  def image_exists?(image_name)
    get_image_id(image_name) != ""
  end

  def get_image_id(image_name)
    command = "docker images -q #{image_name}"

    Indocker::ShellCommands.new.run_command_with_result(command) do |result|
      return result.to_s.strip
    end
  end

  def build_image(image_name)
    Indocker::ShellCommands.new.run_command_with_result(
      "docker build --rm=true -t #{image_name} .", with_sudo: true
    ) do |result|
      return BUILD_IMAGE_ID.match(result).captures.first
    end
  end
end