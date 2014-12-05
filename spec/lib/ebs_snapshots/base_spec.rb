require 'spec_helper'

describe EbsSnapshots::Base do

  let(:base_config) { EbsSnapshots.load_config(EbsSnapshots::Base::BASE_CONFIG) }

  subject { EbsSnapshots::Base.new }

  it "should raise" do
    expect { subject.set_config(nil) }.to raise_error(RuntimeError)
  end

  it "should not raise" do
    expect { subject.set_config({}) }.to_not raise_error
  end

  describe 'config' do
    before(:each) { subject.set_config(config_data) }

    describe 'defaults' do
      let(:config_data) { {} }
      it 'has config defaults' do
        expect(subject.config['retain_for_days']).to eq base_config['retain_for_days']
        expect(subject.config['interval_days']).to eq base_config['interval_days']
        expect(subject.config['intervals']).to eq base_config['intervals']
      end
    end

    describe 'overrides' do
      let(:config_data) { { 'retain_for_days' => 9 } }

      it 'keep untouched defaults' do
        expect(subject.config['retain_for_days']).to eq config_data['retain_for_days']
        expect(subject.config['interval_days']).to eq base_config['interval_days']
        expect(subject.config['intervals']).to eq base_config['intervals']
      end
    end
  end

  describe 'logger' do
    let(:config_data) {
      { 'log_file_path' => '/tmp/test.log', 'log_level' => 'warn'}
    }

    it "should change the logger level" do
      subject.set_config(config_data)
      expect(subject.logger.level).to eq Logger::WARN
    end
  end

end
