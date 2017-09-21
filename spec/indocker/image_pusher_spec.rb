require 'spec_helper'

describe Indocker::ImagePusher do
  subject { ioc.image_pusher }
  
  describe '#push' do
    xit 'pushes image to registry' do
      subject.push('indocker_simple_image', tag: 'latest')
    end
  end
end
