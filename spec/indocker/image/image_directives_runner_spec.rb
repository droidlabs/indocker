require 'spec_helper'

describe Indocker::ImageDirectivesRunner do
  let(:image_directives_runner) { ioc.image_directives_runner }
  let(:project_dir)             { Pathname.new File.expand_path(File.join(__dir__, '../../example')) }

  let(:context) {
    Indocker::DSLContext.new(
      display:    'none',
      use_strict: true,
      build_dir:  build_dir,
      repo:       'indocker_image',
      tag:        'latest'
    )
  }

  let(:build_dir) { ioc.config.build_dir }


  describe '#run_registry' do
    let(:registry_directive) do
      Indocker::ImageDirectives::Registry.new(
        repo:     'indocker_image',
        tag:      'latest',
        registry: 'http://localhost:5000',
        push:     true
      )
    end

    class DockerImageStub
      def tag(*args)
      end

      def push(*args)
      end
    end

    it 'tags image with registry_repotag' do
      allow(Docker::Image).to receive(:get).and_return(DockerImageStub.new)
      expect_any_instance_of(DockerImageStub).to receive(:tag)

      image_directives_runner.run(registry_directive)
    end

    it 'pushes registry_repotag' do
      allow(Docker::Image).to receive(:get).and_return(DockerImageStub.new)
      expect_any_instance_of(DockerImageStub).to receive(:push)

      image_directives_runner.run(registry_directive)
    end
  end

  describe "#run_copy" do
    let(:from_path) { project_dir.join 'assets/.' }
    let(:to_path)   { '/assets' }
    let(:copy_directive) { 
      Indocker::ImageDirectives::Copy.new(
        locals:    context.storage,
        build_dir: context.build_dir, 
        compile:   false,
        copy_actions: { 
          from_path => to_path 
        }
      ) 
    }
    
    context 'for :from as directory path' do
      context "when directory exists" do
        it 'copy files from passed to build directory' do
          image_directives_runner.run(copy_directive)

          ensure_content(File.join(build_dir, 'index.css'), "* { display: <%= display %>; }")
          ensure_content(File.join(build_dir, 'index.js'), "<% if use_strict %>'use strict';<% end %>")
        end
      end

      context 'with compile: true option' do
        let(:copy_directive) { 
          Indocker::ImageDirectives::Copy.new(
            locals:    context.storage,
            build_dir: context.build_dir, 
            compile:   true,
            copy_actions: { 
              from_path => to_path 
            }
          ) 
        }

        it 'copy compiles files from root to build directory' do
          image_directives_runner.run(copy_directive)

          ensure_content(File.join(build_dir, 'index.css'), "* { display: none; }")
          ensure_content(File.join(build_dir, 'index.js'), "'use strict';")
        end
      end
    end

    context "for :from as single file path" do
      let(:from_path) { project_dir.join 'assets/index.css' }
      let(:to_path)   { '/assets' }

      context 'without compilation' do
        it 'copy files from root to build directory if no file in build directory' do
          image_directives_runner.run(copy_directive)
          
          ensure_content(File.join(build_dir, 'index.css'), "* { display: <%= display %>; }")
        end
      end

      context 'with compilaton' do
        let(:copy_directive) { 
          Indocker::ImageDirectives::Copy.new(
            locals:    context.storage,
            build_dir: context.build_dir, 
            compile:   true,
            copy_actions: { 
              from_path => to_path 
            }
          ) 
        }

        it 'compiles and overwrites file is present in build directory' do
          image_directives_runner.run(copy_directive)

          ensure_content(File.join(build_dir, 'index.css'), "* { display: none; }")
        end
      end
    end
  end
end
