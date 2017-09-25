class Indocker::Partial
  attr_reader :name, :definition

  def initialize(name, &definition)
    @name       = name
    @definition = definition
  end
end