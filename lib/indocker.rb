require 'indocker/image_metadata'

module Indocker
  def self.image(name, &block)
    Indocker.images << Indocker::ImageFactory.create(name, &block) 
  end
end