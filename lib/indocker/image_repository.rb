class Indocker::ImageRepository
  def get_image(image_name)
    image = Indocker.images.detect { |image| image.name == image_name }
    raise Indocker::Errors::ImageDoesNotDefined, image_name if image.nil?

    image
  end
end