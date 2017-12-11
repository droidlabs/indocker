module Indocker::Errors         
  class ImageIsNotDefined                 < StandardError; end 
  class ImageIsNotBuilded                 < StandardError; end 
  class PartialIsNotDefined               < StandardError; end 
  class ContainerIsNotDefined             < StandardError; end
  class CircularImageDependency           < StandardError; end
  class ImageForContainerDoesNotExist     < StandardError; end
  class DockerDoesNotInstalled            < StandardError; end
  class ConfigFilesDoesNotFound           < StandardError; end
  class ConfigOptionTypeMismatch          < StandardError; end
  class DockerRegistryAuthenticationError < StandardError; end
  class EnvFileDoesNotExist               < StandardError; end
  class ContainerTimeoutError             < StandardError; end
  class ReservedKeywordUsed               < StandardError; end
  class VolumeIsNotDefined                < StandardError; end
  class NetworkIsNotDefined               < StandardError; end
  class VolumeAlreadyDefined              < StandardError; end

  class ContainerImageAlreadyDefined      < StandardError; end
  class NetworkAlreadyDefined             < StandardError; end
  
  class InvalidParams                     < StandardError; end
end