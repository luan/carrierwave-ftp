require 'spec_helper'
require 'carrierwave/storage/ftptls'

class FtpTlsUploader < CarrierWave::Uploader::Base
  storage :ftptls
end

describe CarrierWave::Storage::FTPTLS do
  before do
    CarrierWave.configure do |config|
      config.reset_config
      config.ftptls_host = 'ftp.testcarrierwave.dev'
      config.ftptls_user = 'test_user'
      config.ftptls_passwd = 'test_passwd'
      config.ftptls_folder = '~/public_html'
      config.ftptls_url = 'http://testcarrierwave.dev'
      config.ftptls_passive = true
    end

    @file = CarrierWave::SanitizedFile.new(file_path('test.jpg'))
    FtpUploader.stub(:store_path).and_return('uploads/test.jpg')
    @storage = CarrierWave::Storage::FTPTLS.new(FtpUploader)
  end

  it "opens/closes an ftptls connection to the given host" do
    ftp = double(:ftp_connection)
    ftp_params = [
      'ftp.testcarrierwave.dev',
      'test_user',
      'test_passwd',
      21
    ]

    Net::FTP.should_receive(:new).and_return(ftp)
    ftp.should_receive(:connect).with('ftp.testcarrierwave.dev', 21)
    ftp.should_receive(:ssl_context=)
    ftp.should_receive(:login).with('test_user', 'test_passwd')
    ftp.should_receive(:passive=).with(true)
    ftp.should_receive(:mkdir_p).with('~/public_html/uploads')
    ftp.should_receive(:chdir).with('~/public_html/uploads')
    ftp.should_receive(:put).with(@file.path, 'test.jpg')
    ftp.should_receive(:quit)
    @stored = @storage.store!(@file)
  end

  describe 'after upload' do
    before do
      ftp = double(:ftp_connection)
      Net::FTP.stub(:new).and_return(ftp)
      ftp.stub(:connect)
      ftp.stub(:ssl_context=)
      ftp.stub(:login)
      ftp.stub(:passive=)
      ftp.stub(:mkdir_p)
      ftp.stub(:chdir)
      ftp.stub(:put)
      ftp.stub(:quit)
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
      @ftp = double(:ftp_connection)
      Net::FTP.stub(:new).and_return(@ftp)
      @ftp.stub(:connect)
      @ftp.stub(:ssl_context=)
      @ftp.stub(:login)
      @ftp.stub(:passive=)
      @ftp.stub(:mkdir_p)
      @ftp.stub(:chdir)
      @ftp.stub(:put)
      @ftp.stub(:quit)
      @stored = @storage.store!(@file)
    end

    it "deletes a file" do
      @ftp.should_receive(:chdir).with('~/public_html/uploads')
      @ftp.should_receive(:delete).with('test.jpg')
      @stored.delete
    end

    it "checks whether a file exists" do
      @stored.should_receive(:size).and_return(10)
      @stored.exists?.should == true
    end

    it "returns the size of the file" do
      @ftp.should_receive(:size).and_return(14)
      @stored.size.should == 14
    end

    it "returns to_file" do
      @ftp.should_receive(:chdir).with('~/public_html/uploads')
      @ftp.should_receive(:get).with('test.jpg', nil).and_yield('some content')
      @stored.to_file.size.should == 'some content'.length
    end

    it "returns the content of the file" do
      @ftp.should_receive(:chdir).with('~/public_html/uploads')
      @ftp.should_receive(:get).with('test.jpg', nil).and_yield('some content')
      @stored.read.should == 'some content'
    end

    it "returns the content_type of the file" do
      @stored.should_receive(:file).and_return(Struct.new(:content_type).new('some/type'))
      @stored.content_type.should == 'some/type'
    end
  end
end
