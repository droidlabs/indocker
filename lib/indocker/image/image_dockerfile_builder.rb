class Indocker::ImageDockerfileBuilder
  include SmartIoC::Iocify

  bean :image_dockerfile_builder

  inject :envs_loader

  def build(*directives)
    dockerfile_content = ""

    dockerfile_content = directives.map do |directive|
      case directive
      when Indocker::ImageDirectives::EnvFile
        env_metadata = envs_loader.parse(directive.path)

        directive.to_s(env_metadata.to_s)
      else
        directive.to_s
      end
    end

    dockerfile_content.join("\n")
  end
end