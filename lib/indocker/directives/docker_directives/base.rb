module Indocker
  module DockerDirectives
    class Base < Indocker::Directives::Base
      attr_reader :args
      
      def initialize(*args)
        @args = args
      end

      def to_s
        "#{type} #{@args.join(' ')}"
      end
    end
  end
end