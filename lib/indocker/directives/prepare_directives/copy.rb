class Indocker::PrepareDirectives::Copy < Indocker::PrepareDirectives::Base
  attr_reader :container_name, :copy_actions, :build_dir

  def initialize(build_dir, copy_hash = {})
    @build_dir    = build_dir
    @copy_actions = []

    copy_hash.each do |from, to|
      @copy_actions.push({ from: from, to: to })
    end
  end
end