class Indocker::TestLogger < Logger
  def initialize
    @strio = StringIO.new
    super(@strio)
  end

  def messages
    @strio.string.split("\n")
  end
end