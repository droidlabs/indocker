class Indocker::ImageDockerfileBuilder
  include SmartIoC::Iocify

  bean :image_dockerfile_builder

  inject :envs_loader

  def build(*directives)
    directives.map do |directive|
      case directive
      when Indocker::ImageDirectives::EnvFile
        env_metadata = envs_loader.parse(directive.path)

        directive.to_dockerfile(env_metadata.to_s)
      else
        directive.to_dockerfile
      end
    end.join("\n")
  end
end