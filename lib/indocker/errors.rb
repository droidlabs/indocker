module Indocker::Errors     
  class ImageDoesNotDefined           < StandardError; end 
  class CircularImageDependency       < StandardError; end
  class ContainerDoesNotDefined       < StandardError; end
  class ImageForContainerDoesNotExist < StandardError; end
end