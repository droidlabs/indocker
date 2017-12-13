require 'spec_helper'

describe Indocker::FileUtils do
  subject(:file_uitls) { ioc.file_utils }

  let(:example_directory) { File.expand_path('../../example', __dir__) }
  let(:tmp_directory)     { File.expand_path('../../../tmp', __dir__) }

  after(:each) { FileUtils.rm_rf File.join(tmp_directory, '.') }

  describe '#cp_r_with_modify' do
    context 'from file to file' do
      let(:source)        { File.join(example_directory, 'assets/index.css') }
      let(:invalid_file)  { File.join(example_directory, 'i/do/not/exists') }
      let(:destination)   { File.join(tmp_directory, 'assets/index.scss') }

      it 'copies file to passed destination' do
        file_uitls.cp_r_with_modify(from: source, to: destination)

        ensure_content(destination, '* { display: <%= display %>; }')
      end

      it 'copies file with modifying content and chmods' do
        file_uitls.cp_r_with_modify(from: source, to: destination) do |file|
          File.write(file, File.read(file).upcase)
        end

        ensure_content(destination, '* { DISPLAY: <%= DISPLAY %>; }')
      end
    end

    context 'from file to directory' do
      let(:source)      { File.join(example_directory, 'assets/index.css') }
      let(:destination) { File.join(tmp_directory, 'assets') }

      it 'copies file to passed destination' do
        file_uitls.cp_r_with_modify(from: source, to: destination)

        ensure_content(File.join(destination, 'index.css'), '* { display: <%= display %>; }')
      end
    end

    context 'from directory to directory' do
      let(:source)      { File.join(example_directory, 'assets/') }
      let(:destination) { File.join(tmp_directory) }

      it 'copies file to passed destination' do
        file_uitls.cp_r_with_modify(from: source, to: destination)

        ensure_content(File.join(destination, 'index.css'), '* { display: <%= display %>; }')
        ensure_content(File.join(destination, 'index.js'), "<% if use_strict %>'use strict';<% end %>")
      end
    end

    context 'from directory to directory with out current folder (/.)' do
      let(:source)      { File.join(example_directory, 'assets/.') }
      let(:destination) { File.join(tmp_directory, 'assets') }

      it 'copies file to passed destination' do
        file_uitls.cp_r_with_modify(from: source, to: destination)

        ensure_content(File.join(destination, 'index.css'), '* { display: <%= display %>; }')
        ensure_content(File.join(destination, 'index.js'), "<% if use_strict %>'use strict';<% end %>")
      end
    end

    context 'from directory to directory using glob' do
      let(:source)      { File.join(example_directory, 'assets/*.css') }
      let(:destination) { File.join(tmp_directory, 'assets') }

      it 'copies file to passed destination' do
        file_uitls.cp_r_with_modify(from: source, to: destination)

        ensure_content(File.join(destination, 'index.css'), '* { display: <%= display %>; }')
        expect(
          File.exists? File.join(destination, 'index.js')
        ).to be false
      end
    end
  end
end