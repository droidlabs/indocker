require 'erb'

module Indocker::Utils
  class RenderUtil
    include SmartIoC::Iocify

    bean :render_util

    def render(template, locals)
      namespace = Indocker::Utils::RenderNamespace.new(locals)

      ERB.new(template).result(namespace.get_binding)
    end
  end
end
