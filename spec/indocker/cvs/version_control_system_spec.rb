require_relative '../../../lib/indocker/cvs/version_control_system.rb'

describe  'VersionControlSystem' do 
 
  context 'branch' do
    before do
      @version_control_system = VersionControlSystem.new("https://github.com/schacon/ruby-git", "test", nil, "workdir")
    end

    it 'uses to pull from branch' do
      expect(@version_control_system.use).to be_instance_of(PullBranch)
    end

    it 'exists directory' do
      directory = File.expand_path(File.join("workdir", "branches", "test"))
      expect(Dir.exist?(directory)).to be(true)
    end

  end

  context 'tag' do
    before do
      @version_control_system = VersionControlSystem.new("https://github.com/schacon/ruby-git", nil, "v1.2.3", "workdir")
    end

    it 'uses to pull from tag' do
      expect(@version_control_system.use).to be_instance_of(PullTag)
    end

    it 'exists directory' do
      directory = File.expand_path(File.join("workdir", "tags", "v1.2.3"))
      expect(Dir.exist?(directory)).to be(true)
    end

  end

end