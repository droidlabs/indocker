module Indocker::Commands
  class Base
    def initialize(*args)
      @args = args
    end

    def to_s
      "#{type} #{@args.join(' ')}"
    end
  end

  class From    < Indocker::Commands::Base
    def type
      'FROM'
    end
  end
  class Workdir < Indocker::Commands::Base
    def type
      'WORKDIR'
    end
  end
  class Run     < Indocker::Commands::Base
    def type
      'RUN'
    end
  end

  class BeforeBuild
    attr_reader :definition, :containers

    def initialize(&definition)
      @definition = definition
      @containers = []
    end

    def get_containers
      instance_exec &definition

      containers
    end

    private

    def run_container(name)
      @containers.push(name)
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