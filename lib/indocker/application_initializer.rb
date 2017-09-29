class Indocker::ApplicationInitializer
  include SmartIoC::Iocify

  bean :application_initializer

  def init_app
    load "~/data/planiro/.indocker/config.rb"
  end
end