require 'settei/generators/rails'
require 'rails/generators/rails/app/app_generator'

RSpec.describe Settei::Generators::Rails do
  it 'generates files' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Rails::Generators::AppGenerator.start ['foo', '--skip-bundle']

        app_path = File.join(dir, 'foo')

        expect(File.exist?(File.join(app_path, 'config/setting.rb'))).to eq(false)
        expect(File.exist?(File.join(app_path, 'config/environments/development.yml'))).to eq(false)
        expect(File.exist?(File.join(app_path, 'config/environments/test.yml'))).to eq(false)
        expect(File.exist?(File.join(app_path, 'config/environments/production.yml'))).to eq(false)
        expect(File.read(File.join(app_path, '.gitignore'))).to_not include("config/environments/*.yml")

        subject = described_class.new(app_path: app_path)
        subject.run

        expect(File.read(File.join(app_path, 'config/setting.rb'))).to include("require 'settei'")

        expect(File.exist?(File.join(app_path, 'config/environments/development.yml'))).to eq(true)
        expect(File.exist?(File.join(app_path, 'config/environments/test.yml'))).to eq(true)
        expect(File.exist?(File.join(app_path, 'config/environments/production.yml'))).to eq(true)

        expect(File.read(File.join(app_path, '.gitignore'))).to include("config/environments/*.yml")
      end
    end
  end

  it 'skips if already generated' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Rails::Generators::AppGenerator.start ['foo', '--skip-bundle']

        app_path = File.join(dir, 'foo')

        File.open(File.join(app_path, 'config/setting.rb'), 'w+')  {|f|f.write("foo") }
        File.open(File.join(app_path, 'config/environments/development.yml'), 'w+')  {|f|f.write("foo") }
        File.open(File.join(app_path, 'config/environments/test.yml'), 'w+')  {|f|f.write("foo") }
        File.open(File.join(app_path, 'config/environments/production.yml'), 'w+')  {|f|f.write("foo") }
        File.open(File.join(app_path, '.gitignore'), 'w+')  {|f|f.write("foo") }

        subject = described_class.new(app_path: app_path)
        subject.run
        subject.run

        expect(File.read(File.join(app_path, 'config/setting.rb'))).to eq('foo')

        expect(File.read(File.join(app_path, 'config/environments/development.yml'))).to eq('foo')
        expect(File.read(File.join(app_path, 'config/environments/test.yml'))).to eq('foo')
        expect(File.read(File.join(app_path, 'config/environments/production.yml'))).to eq('foo')

        gitignore_content = File.read(File.join(app_path, '.gitignore'))
        expect(gitignore_content.scan("/config/environments/*.yml").length).to eq(1)
      end
    end
  end
end