class Indocker::DockerDirectives::Copy < Indocker::DockerDirectives::Base
  attr_reader :copy_actions

  def initialize(copy_actions)
    @copy_actions = copy_actions
  end

  def type
    'COPY'
  end

  def to_s
    result = []
    
    copy_actions.each do |from, to|
      result.push "#{type} #{from} #{to}"
    end

    result.join("\n")
  end
end