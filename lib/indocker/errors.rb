module Indocker::Errors     
  class ImageIsNotDefined             < StandardError; end 
  class PartialIsNotDefined           < StandardError; end 
  class ContainerIsNotDefined         < StandardError; end
  class CircularImageDependency       < StandardError; end
  class ImageForContainerDoesNotExist < StandardError; end
end