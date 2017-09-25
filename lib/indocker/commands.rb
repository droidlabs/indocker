module Indocker::Commands
  class Base
    def initialize(*args)
      @args = args
    end
  end

  class From    < Indocker::Commands::Base; end
  class Workdir < Indocker::Commands::Base; end
  class Run     < Indocker::Commands::Base; end

  class BeforeBuild
    def initialize(&block)
      @block = block
    end
  end

  class Partial
    attr_reader :name, :context

    def initialize(name, context, opts = {})
      @name    = name
      @context = context
      @opts    = opts
    end
  end
end