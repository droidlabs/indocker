require 'dto'

class Indocker::CopyActionDTO < DTO::Base
  attrs :from, :to
end