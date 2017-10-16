class Indocker::DockerDirectives::CopyRoot < Indocker::DockerDirectives::Copy
  attr_reader :build_dir, :copy_actions

  def initialize(build_dir, copy_actions)
    @build_dir    = build_dir
    @copy_actions = copy_actions
  end

  def to_s
    result = []
    
    copy_actions.each do |from, to|
      result.push "#{type} #{from} #{to}"
    end

    result.join("\n")
  end

  def prepare_directive?
    true
  end
end