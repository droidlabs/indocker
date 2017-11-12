module Indocker::ContainerDirectives
  class Base < Indocker::Directives::Base
    def container_directive?
      true
    end

    def before_start?
      false
    end

    def after_start?
      false
    end

    def before_stop?
      false
    end

    def after_stop?
      false
    end
  end
end