class Indocker::ContainerDirectives::Ready < Indocker::ContainerDirectives::Base
  attr_accessor :ready_block, :sleep, :timeout

  DEFAULT_SLEEP   = 0.1
  DEFAULT_TIMEPUT = 10

  def initialize(sleep: DEFAULT_SLEEP, timeout: DEFAULT_TIMEPUT, ready_block:)
    @sleep       = sleep
    @timeout     = timeout
    @ready_block = ready_block
  end

  def after_start?
    true
  end
end