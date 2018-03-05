require 'settei/generators/rails'
require 'rails/generators/rails/app/app_generator'
require 'tmpdir'

RSpec.describe Settei::Generators::Rails do
  let(:template_path) { File.join(File.dirname(__FILE__), '..', '..', 'templates') }
  let(:setting_rb_content) { File.read(File.join(template_path, 'setting.rb')) }
  let(:setting_yml_content) { File.read(File.join(template_path, 'setting.yml')) }

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

        expect(File.read(File.join(app_path, 'config/setting.rb'))).to eq(setting_rb_content)

        expect(File.read(File.join(app_path, 'config/environments/development.yml'))).to eq(setting_yml_content)
        expect(File.read(File.join(app_path, 'config/environments/test.yml'))).to eq(setting_yml_content)
        expect(File.read(File.join(app_path, 'config/environments/production.yml'))).to eq(setting_yml_content)

        expect(File.read(File.join(app_path, 'config/boot.rb'))).to include("require_relative 'setting'")
        expect(File.read(File.join(app_path, '.gitignore'))).to include("config/environments/*.yml")
      end
    end
  end

  it 'skips if already generated' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Rails::Generators::AppGenerator.start ['foo', '--skip-bundle']

        existing_content = 'bar'
        app_path = File.join(dir, existing_content)

        File.write(File.join(app_path, 'config/setting.rb'), existing_content)
        File.write(File.join(app_path, 'config/environments/development.yml'), existing_content)
        File.write(File.join(app_path, 'config/environments/test.yml'), existing_content)
        File.write(File.join(app_path, 'config/environments/production.yml'), existing_content)
        File.write(File.join(app_path, '.gitignore'), existing_content)

        subject = described_class.new(app_path: app_path)
        subject.run
        subject.run

        # Ensure not changed
        expect(File.read(File.join(app_path, 'config/setting.rb'))).to eq(existing_content)
        expect(File.read(File.join(app_path, 'config/environments/development.yml'))).to eq(existing_content)
        expect(File.read(File.join(app_path, 'config/environments/test.yml'))).to eq(existing_content)
        expect(File.read(File.join(app_path, 'config/environments/production.yml'))).to eq(existing_content)

        boot_content = File.read(File.join(app_path, 'config/boot.rb'))
        expect(boot_content.scan("require_relative 'setting'").length).to eq(1)

        gitignore_content = File.read(File.join(app_path, '.gitignore'))
        expect(gitignore_content.scan("/config/environments/*.yml").length).to eq(1)
      end
    end
  end
end