require 'spec_helper'

describe Indocker::ImageDirectivesRunner do
  let(:image_directives_runner) { ioc.image_directives_runner }

  let(:context) {
    Indocker::DSLContext.new(
      display:    'none',
      use_strict: true,
      build_dir:  build_dir
    )
  }

  let(:directive) { 
    Indocker::DockerDirectives::Copy.new(
      context: context, 
      compile: false,
      copy_actions: { 
        from_path => to_path 
      }
    ) 
  }

  let(:from_path) { 'assets/.' }
  let(:to_path)   { '/assets' }

  describe "#run_copy" do
    let(:build_dir) { ioc.config.build_dir }
    
    context 'for :from as directory path' do
      context "when directory exists" do
        it 'copy files from passed to build directory' do
          image_directives_runner.run(directive)

          ensure_content(build_dir.join('assets', 'index.css'), "* { display: <%= display %>; }")
          ensure_content(build_dir.join('assets', 'index.js'), "<% if use_strict %>'use strict';<% end %>")
        end
      end

      context "when directory does not exists" do
        let(:from_path) { 'invalid/dir/.' }
        let(:to_path)   { '/invalid/dir' }

        it "raises error Indocker::Errors::FileNotExists" do
          expect{
            image_directives_runner.run(directive)
          }.to raise_error(Indocker::Errors::FileNotExists)
        end
      end

      context 'with compile: true option' do
        let(:directive) { 
          Indocker::DockerDirectives::Copy.new(
            context: context, 
            compile: true,
            copy_actions: { 
              from_path => to_path 
            }
          ) 
        }

        it 'copy compiles files from root to build directory' do
          image_directives_runner.run(directive)

          ensure_content(build_dir.join('assets', 'index.css'), "* { display: none; }")
          ensure_content(build_dir.join('assets', 'index.js'), "'use strict';")
        end
      end
    end

    context "for :from as single file path" do
      let(:from_path) { 'assets/index.css' }
      let(:to_path)   { '/assets' }

      context 'without compilation' do
        it 'copy files from root to build directory if no file in build directory' do
          image_directives_runner.run(directive)
          
          ensure_content(build_dir.join('assets', 'index.css'), "* { display: <%= display %>; }")
        end
      end

      context 'with compilaton' do
        let(:directive) { 
          Indocker::DockerDirectives::Copy.new(
            context: context, 
            compile: true,
            copy_actions: { 
              from_path => to_path 
            }
          ) 
        }
        
        before do
          FileUtils.mkdir_p(File.join(build_dir, 'assets'))
          File.open(build_dir.join('assets', 'index.css'), 'w') {|f| f.write("/* <%= display %>; */")}
        end

        it 'compiles and overwrites file is present in build directory' do
          image_directives_runner.run(directive)

          ensure_content(build_dir.join('assets', 'index.css'), "/* none; */")
        end
      end
    end
  end
end
