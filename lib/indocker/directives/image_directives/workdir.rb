class Indocker::ImageDirectives::Workdir < Indocker::ImageDirectives::Base
  def type
    'WORKDIR'
  end

  def build_directive?
    true
  end
end