class Indocker::ContainerEvaluator
  include SmartIoC::Iocify

  bean :container_evaluator

  def evaluate(context, &block)
    container_dsl = Indocker::ContainerDSL.new(context)

    container_dsl.instance_exec(&block)

    container_dsl.directives
  end
end