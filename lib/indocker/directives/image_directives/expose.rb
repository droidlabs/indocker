class Indocker::ImageDirectives::Expose < Indocker::ImageDirectives::Base
  def type
    'EXPOSE'
  end

  def build_directive?
    true
  end
end