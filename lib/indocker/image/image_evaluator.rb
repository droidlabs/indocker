class Indocker::ImageEvaluator
  include SmartIoC::Iocify

  bean   :image_evaluator
  inject :partial_metadata_repository

  def evaluate(context, &block)
    image_dsl = Indocker::ImageDSL.new(context)
    
    image_dsl.instance_eval(&block)
    
    image_dsl.directives
      .map do |directive|
        next directive if !directive.partial_directive?

        partial = partial_metadata_repository.find_by_name(directive.name)
        evaluate(directive.context, &partial.definition)
      end
      .flatten
  end
end