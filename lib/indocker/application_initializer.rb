class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  def init_app
    require "~/data/planiro/.indocker/config"
  end
end