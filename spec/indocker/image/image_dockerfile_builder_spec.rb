require 'spec_helper'

describe Indocker::ImageDockerfileBuilder do
  subject { ioc.image_dockerfile_builder }
  
  describe '#build' do
    let(:from_directive)     { Indocker::DockerDirectives::From.new('ruby-alpine:latest') }
    let(:workdir_directive)  { Indocker::DockerDirectives::Workdir.new('/app') }
    let(:env_file_directive) { 
      Indocker::DockerDirectives::EnvFile.new(
        File.expand_path(File.join(__dir__, '../../fixtures/spec.env'))
      ) 
    }

    it 'generates valid dockerfile' do
      expect(
        subject.build(from_directive, workdir_directive, env_file_directive)
      ).to eq(
        "FROM ruby-alpine:latest\n" <<
        "WORKDIR /app\n" <<
        "ENV RUBY_ENV=development RAILS_ENV=development"
      )
    end
  end
end