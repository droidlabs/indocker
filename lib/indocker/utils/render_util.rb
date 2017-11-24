require 'erb'

module Indocker::Utils
  class RenderUtil
    include SmartIoC::Iocify

    bean :render_util

    def render(template, locals)
      namespace = Namespace.new(locals)

      ERB.new(template).result(namespace.get_binding)
    end

    class Namespace
      def initialize(hash)
        hash.each do |key, value|
          singleton_class.send(:define_method, key) { value }
        end
      end
    
      def get_binding
        binding
      end
    end
  end
end
