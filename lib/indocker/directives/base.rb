module Indocker
  module Directives
    class Base
      def partial_directive?
        false
      end

      def container_directive?
        false
      end

      def image_directive?
        false
      end
    end
  end
end