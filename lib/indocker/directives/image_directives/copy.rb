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

  def to_dockerfile
    copy_actions
      .map { |ca| "#{type} #{ca.to} #{ca.to}" }
      .join("\n")
  end

  def prepare_directive?
    true
  end

  def build_directive?
    true
  end
end