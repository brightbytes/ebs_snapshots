require 'spec_helper'

describe EbsSnapshots do
#  subject { EbsSnapshots }

  let(:config_fixture) { File.absolute_path(File.join(__FILE__, '../../fixtures/config.yml')) }
  let(:expected) { { 'log_level' => 'warn' } }

  it "should parse a yaml" do
    expect(subject.load_config(config_fixture)).to eq expected
  end

end
