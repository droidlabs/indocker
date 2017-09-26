class Indocker::ImageEvaluator
  include SmartIoC::Iocify

  bean   :image_evaluator
  inject :partial_repository

  def evaluate(context = Indocker::ImageContext.new, &block)
    image_dsl = Indocker::ImageDSL.new(context)
    image_dsl.instance_eval(&block)

    image_dsl.commands
      .map do |command|
        next command if !command.instance_of?(Indocker::Commands::Partial)

        partial = partial_repository.find_by_name(command.name)
        evaluate(command.context, &partial.definition)
      end
      .flatten
  end
end