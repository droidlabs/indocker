class Indocker::ImageMetadata
  DEFAULT_TAG = 'latest'

  attr_reader   :repository, :tag, :definition
  attr_accessor :id

  def initialize(repository, &definition)
    @repository = repository
    @tag        = DEFAULT_TAG
    @definition = definition
  end

  def full_name
    "#{repository}:#{tag}"
  end

  def build_dir
    File.join(Indocker.root, Indocker::BUILD_DIR, repository)
  end
end