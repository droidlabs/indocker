class Indocker::Configs::Option
  attr_reader :value, :required, :type, :group

  def initialize(name:, value:, required: nil, type: nil, group: nil)
    @name     = name
    @value    = value
    @required = required || false
    @type     = type     || :string
    @group    = group    || :default
  end

  def validate!
    check_required
    check_type
  end

  private

  def check_required
    if @required && @value.nil?
      raise Indocker::Errors::ConfigInitializationError, 
        "Configuration option :#{option} is required"
    end
  end

  def check_type
    @value = cast_value_to_type(@value, @type)
    value_type = cast_class_to_type(@value)
    
    if @type != value_type
      raise Indocker::Errors::ConfigOptionTypeMismatch, 
        "Expected option #{@name.inspect} => #{@value.inspect} to be a #{@type.inspect}, not a #{value_type.inspect}"
    end

    nil
  end

  def cast_class_to_type(value)
    case value
    when Proc
      cast_class_to_type(value.call)
    when TrueClass
      :boolean
    when FalseClass
      :boolean
    when Indocker::Configs::Config
      :config
    else
      Indocker::StringUtils.underscore(value.class.name).to_sym
    end
  end

  def cast_value_to_type(val, type)
    case type
    when :pathname
      val.is_a?(Pathname) ? val : Pathname.new(val)
    else
      val
    end
  end
end