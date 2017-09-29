class Indocker::PartialMetadata
  attr_reader :name, :definition

  def initialize(name, &definition)
    @name       = name
    @definition = definition
  end
end