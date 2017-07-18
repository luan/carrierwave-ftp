require 'spec_helper'
require 'carrierwave/storage/ftp'
require 'ftpd'

class FtpUploader < CarrierWave::Uploader::Base
  storage :ftp
end

describe CarrierWave::Storage::FTP do
  describe 'with a real ftp server' do
    # Remote Setup
    let(:tmpdir) { Dir.mktmpdir }

    let(:ftp_server) do
      driver = double('Driver',
        authenticate: true,
        file_system: Ftpd::DiskFileSystem.new(tmpdir)
      )
      Ftpd::FtpServer.new(driver)
    end

    # Local Setup
    let(:uploader_class) do
      bound_port = ftp_server.bound_port
      Class.new(CarrierWave::Uploader::Base) do
        storage CarrierWave::Storage::FTP

        ftp_host 'localhost'
        ftp_port bound_port
        ftp_user 'test_user'
        ftp_passwd 'test_passwd'
        ftp_folder '/ftp_dir'
        ftp_url 'http://testcarrierwave.dev'
        ftp_passive true

        def store_path(*)
          "uploads/test.txt"
        end
      end
    end
    subject { CarrierWave::Storage::FTP.new(uploader_class.new) }


    before(:each) do
      ftp_server.start

      local_file = CarrierWave::SanitizedFile.new(file_path('test.txt'))
      @stored_file = subject.store!(local_file)
      @remote_path = "#{tmpdir}/ftp_dir/uploads/test.txt"
    end

    after(:each) do
      ftp_server.stop
      FileUtils.remove_entry_secure tmpdir
    end


    ### Tests
    it "stores the file remotely" do
      File.exists?(@remote_path).should == true
      File.read(@remote_path).should == 'test content'
    end

    it "can delete the file" do
      @stored_file.delete
      File.exists?(@remote_path).should == false
    end

    it "can check existence" do
      @stored_file.exists?.should == true
    end

    it "can check the size" do
      @stored_file.size.should == 12
    end
  end
end
