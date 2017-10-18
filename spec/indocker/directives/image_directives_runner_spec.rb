require 'spec_helper'

describe Indocker::ImageDirectivesRunner do
  let(:image_directives_runner) { ioc.image_directives_runner }

  describe "#run" do
    context "for 'copy_root' command" do
      let(:build_dir) { ioc.config.root.join('../../tmp/build_dir') }
      let(:from_path) { 'assets/.' }
      let(:to_path)   { '/assets' }
      let(:directive) { 
        Indocker::DockerDirectives::CopyRoot.new(build_dir, { from_path => to_path }) 
      }

      it 'copy files from root to build directory' do
        image_directives_runner.run(directive)

        ensure_exists(build_dir.join('assets', 'index.css'))
        ensure_exists(build_dir.join('assets', 'index.js'))
      end
    end
  end
end