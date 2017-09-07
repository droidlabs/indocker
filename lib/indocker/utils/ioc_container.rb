require 'smart_ioc'

class IocContainer
  class << self
    def [](meth, *args)
      SmartIoC::Container.get_instance.get_bean(meth, *args)
    end
  end

  def self.method_missing(meth, *args, &block)
    SmartIoC::Container.get_instance.get_bean(meth, *args)
  end
end

def ioc
  IocContainer
end