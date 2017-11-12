class Indocker::ImageDirectives::Env < Indocker::ImageDirectives::Base
  def type
    'ENV'
  end

  def build_directive?
    true
  end
end