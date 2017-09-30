module Indocker
  module Directives
    class Base
      def partial?
        self.is_a?(Indocker::Directives::Partial)
      end

      def prepare_directive?
        self.is_a?(Indocker::PrepareDirectives::Base)
      end

      def build_directive?
        self.is_a?(Indocker::DockerDirectives::Base)
      end
    end
  end
end