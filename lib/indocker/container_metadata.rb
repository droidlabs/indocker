class Indocker::ContainerMetadata
  attr_reader :name, :from
  attr_accessor :id

  def initialize(name, from:)
    @name = name
    @from = from
  end
end