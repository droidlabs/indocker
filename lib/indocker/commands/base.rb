module Indocker::Commands
  class Base
    def initialize(*args)
      @args = args
    end

    def to_s
      "#{type} #{@args.join(' ')}"
    end
  end

  class From < Indocker::Commands::Base
    def type
      'FROM'
    end
  end

  class Workdir < Indocker::Commands::Base
    def type
      'WORKDIR'
    end
  end
  
  class Run < Indocker::Commands::Base
    def type
      'RUN'
    end
  end
  
  class Run < Indocker::Commands::Base
    def type
      'RUN'
    end
  end
  
  class Cmd < Indocker::Commands::Base
    def type
      'CMD'
    end
  end
  
  class Copy < Indocker::Commands::Base
    def type
      'COPY'
    end
  end
end