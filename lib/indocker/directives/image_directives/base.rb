module Indocker
  module ImageDirectives
    class Base < Indocker::Directives::Base
      attr_reader :args
      
      def initialize(*args)
        @args = args
      end

      def to_s
        "#{type} #{@args.join(' ')}"
      end

      def prepare_directive?
        false
      end

      def build_directive?
        false
      end

      def after_build_directive?
        false
      end
    end
  end
end