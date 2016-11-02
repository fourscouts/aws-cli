require 'spec_helper'

describe "Container" do

  before(:all) do
    @image = Docker::Image.build_from_dir($project_root)

    set :docker_image, @image.id
  end

  describe 'when running' do
    before(:all) do
      @container = Docker::Container.create(
          'Image' => @image.id,
          'Cmd' => ['bash']
      )
      @container.start()

      set :docker_container, @container.id
    end


    it "runs alpine version 3.4" do
      expect(file('/etc/os-release')).to be_a_file
      os_version = command('cat /etc/os-release')
      expect(os_version.stdout).to include('PRETTY_NAME="Alpine Linux v3.4"')
    end

    it "has the declared version of aws-cli tools installed" do
      version = command('aws --version')
      # don't know why, but aws-cli outputs version info in stderr
      expect(version.stderr).to include('1.11.11')
    end

    requiredPackages = %w(
        bash
        bash-completion
        groff
        less
        curl
        jq
        build-base
        py-pip
        python
    )

    requiredPackages.each { |apkPackage|
      describe package(apkPackage) do
        it { is_expected.to be_installed }
      end
    }

    after(:all) do
      @container.kill
      @container.delete(:force => true)
    end
  end
end
