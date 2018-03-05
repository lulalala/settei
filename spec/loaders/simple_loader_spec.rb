require 'settei/loaders/simple_loader'
require 'yaml'

RSpec.describe Settei::Loaders::SimpleLoader do
  let(:hash) {
    {
      a: 0,
      b: {
        c: 1
      }
    }
  }
  let(:yaml) { YAML.dump(hash) }

  describe 'to_hash' do
    it 'loads default file' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir,'default.yml'), yaml)

        subject = described_class.new(dir: dir)

        expect(subject.load.as_hash).to eq(hash)
      end
    end

    it 'loads default file when file specified by environment does not exist' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir,'default.yml'), yaml)

        subject = described_class.new(dir: dir)

        expect(subject.load('development').as_hash).to eq(hash)
      end
    end

    it 'loads file specified by environment' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir,'development.yml'), yaml)

        subject = described_class.new(dir: dir)

        expect(subject.load('development').as_hash).to eq(hash)
      end
    end


    it 'loads file specified by environment' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir,'development.yml'), yaml)

        subject = described_class.new(dir: dir)
        subject.load('development')

        expect(subject.as_hash).to eq(hash)
      end
    end
  end

  describe 'environment variable' do
    let(:env_name) { "FOO_CONFIG" }

    it 'loads from environment variable' do
      local_loader = nil

      Dir.mktmpdir do |dir|
        File.write(File.join(dir,'default.yml'), yaml)

        local_loader = described_class.new(dir: dir, env_name: env_name)
        expect(local_loader.load.as_env_assignment).to eq("#{env_name}=#{local_loader.as_env_value}")
      end

      ENV[env_name] = local_loader.as_env_value

      remote_loader = described_class.new(env_name: env_name)
      expect(remote_loader.load.as_hash).to eq(hash)

      ENV.delete(env_name)
    end

    it 'loads from environment variable by default APP_CONFIG key' do
      local_loader = nil

      Dir.mktmpdir do |dir|
        File.write(File.join(dir,'default.yml'), yaml)

        local_loader = described_class.new(dir: dir)
        expect(local_loader.load.as_env_assignment).to eq("APP_CONFIG=#{local_loader.as_env_value}")
      end

      ENV['APP_CONFIG'] = local_loader.as_env_value

      remote_loader = described_class.new
      expect(remote_loader.load.as_hash).to eq(hash)

      ENV.delete('APP_CONFIG')
    end
  end
end