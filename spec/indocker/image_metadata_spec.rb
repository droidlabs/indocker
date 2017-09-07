require 'spec_helper'

describe Indocker::ImageMetadata do
  subject do
    described_class.new 'simple_image' do
      before_build do
        "I am before_build string"
      end

      from    'ruby:2.3.1'
      copy    '.', '.'
      workdir '/app'
      cmd     ['echo', 'Hello World']
    end
  end

  it 'keep before_build block' do
    expect(subject.before_build_block.call).to eq("I am before_build string")
  end

  it 'keep docker commands to dockerfile content' do
    expect(subject.to_dockerfile).to eq(
      <<~EOL.strip
        FROM ruby:2.3.1
        COPY . .
        WORKDIR /app
        CMD ["echo", "Hello World"]
      EOL
    )
  end
end