class Indocker::DockerDirectives::Copy < Indocker::DockerDirectives::Base
  attr_reader :copy_actions, :context, :compile

  def initialize(context:, copy_actions:, compile:)
    @context      = context
    @copy_actions = copy_actions
    @compile      = compile
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

  def prepare_directive?
    true
  end
end