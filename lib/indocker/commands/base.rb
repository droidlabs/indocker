module Indocker::Commands
  class Base
    attr_reader :args
    
    def initialize(*args)
      @args = args
    end

    def to_s
      "#{type} #{@args.join(' ')}"
    end
  end

  class From < Indocker::Commands::Base
    attr_reader :repo, :tag

    def initialize(repo_tag, tag: nil)
      @repo = repo_tag.split(':')[0]
      @tag  = tag || repo_tag.split(':')[1] || Indocker::ImageMetadata::DEFAULT_TAG
    end

    def dockerhub_image?
      repo.is_a?(String)
    end

    def to_s
      "#{type} #{repo}:#{tag}"
    end

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
  
  class Entrypoint < Indocker::Commands::Base
    def type
      'ENTRYPOINT'
    end
  end
end