require 'spec_helper'
require 'carrierwave/storage/sftp'

class SftpUploader < CarrierWave::Uploader::Base
  storage :sftp
end

describe CarrierWave::Storage::SFTP do
  before do
    CarrierWave.configure do |config|
      config.reset_config
      config.sftp_host = 'testcarrierwave.dev'
      config.sftp_user = 'test_user'
      config.sftp_folder = '/home/test_user/public_html'
      config.sftp_url = 'http://testcarrierwave.dev'
      config.sftp_options = {
        :password => 'test_passwd',
        :port     => 22
      }
    end

    @file = CarrierWave::SanitizedFile.new(file_path('test.jpg'))
    SftpUploader.stub!(:store_path).and_return('uploads/test.jpg')
    @storage = CarrierWave::Storage::SFTP.new(SftpUploader)
  end

  it "opens/closes an ftp connection to the given host" do
    sftp = double(:sftp_connection)
    sftp_params = [
      'testcarrierwave.dev',
      'test_user',
      {
        :password => 'test_passwd',
        :port     => 22
      }
    ]

    Net::SFTP.should_receive(:start).with(*sftp_params).and_return(sftp)
    sftp.should_receive(:mkdir_p!).with('/home/test_user/public_html/uploads')
    sftp.should_receive(:upload!).with(@file.path, '/home/test_user/public_html/uploads/test.jpg')
    sftp.should_receive(:close_channel)
    @stored = @storage.store!(@file)
  end

  describe 'after upload' do
    before do
      sftp = double(:sftp_connection)
      Net::SFTP.stub(:start).and_return(sftp)
      sftp.stub(:mkdir_p!)
      sftp.stub(:upload!)
      sftp.stub(:close_channel)
      @stored = @storage.store!(@file)
    end

    it "returns a url based on directory" do
      @stored.url.should == 'http://testcarrierwave.dev/uploads/test.jpg'
    end

    it "returns a path based on directory" do
      @stored.path.should == 'uploads/test.jpg'
    end
  end

  describe 'other operations' do
    before do
      @sftp = double(:sftp_connection)
      Net::SFTP.stub(:start).and_return(@sftp)
      @sftp.stub(:mkdir_p!)
      @sftp.stub(:upload!)
      @sftp.stub(:close_channel)
      @stored = @storage.store!(@file)
    end

    it "deletes a file" do
      @sftp.should_receive(:remove!).with('/home/test_user/public_html/uploads/test.jpg')
      @stored.delete
    end

    it "checks whether a file exists" do
      @stored.should_receive(:size).and_return(10)
      @stored.exists?.should == true
    end

    it "returns the size of the file" do
      @sftp.should_receive(:stat!).with('/home/test_user/public_html/uploads/test.jpg')
          .and_return(Struct.new(:size).new(14))
      @stored.size.should == 14
    end

    it "returns the content of the file" do
      @stored.should_receive(:file).and_return(Struct.new(:body).new('some content'))
      @stored.read.should == 'some content'
    end

    it "returns the content_type of the file" do
      @stored.should_receive(:file).and_return(Struct.new(:content_type).new('some/type'))
      @stored.content_type.should == 'some/type'
    end
  end
end
