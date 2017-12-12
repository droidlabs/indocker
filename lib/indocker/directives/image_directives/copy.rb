class Indocker::ImageDirectives::Copy < Indocker::ImageDirectives::Base
  attr_reader :copy_actions, :compile, :locals, :build_dir

  def initialize(copy_actions:, compile:, locals:, build_dir:)
    @copy_actions = copy_actions
    @compile      = compile
    @locals       = locals
    @build_dir    = build_dir
  end

  def type
    'COPY'
  end

  def to_s
    result = []
    copy_actions.each do |from, to|
      result.push "#{type} #{File.basename(from)} #{to}"
    end

    result.join("\n")
  end

  def prepare_directive?
    true
  end

  def build_directive?
    true
  end
end