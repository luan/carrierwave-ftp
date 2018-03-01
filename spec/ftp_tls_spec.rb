require 'spec_helper'
require 'carrierwave/storage/ftp'

class FtpTlsUploader < CarrierWave::Uploader::Base
  storage :ftp
end

describe CarrierWave::Storage::FTP do
  before do
    FtpTlsUploader.configure do |config|
      config.reset_config
      config.ftp_host = 'ftp.testcarrierwave.dev'
      config.ftp_user = 'test_user'
      config.ftp_passwd = 'test_passwd'
      config.ftp_folder = '~/public_html'
      config.ftp_url = 'http://testcarrierwave.dev'
      config.ftp_passive = true
      config.ftp_tls = true
      config.ftp_chmod = true
    end

    @file = CarrierWave::SanitizedFile.new(file_path('test.jpg'))
    allow(FtpTlsUploader).to receive(:store_path).and_return('uploads/test.jpg')
    @storage = CarrierWave::Storage::FTP.new(FtpTlsUploader)
  end

  it 'opens/closes a secure ftp connection to the given host' do
    ftp = double(:ftp_connection)
    expect(Net::FTP).to receive(:new).and_return(ftp)
    expect(ftp).to receive(:sendcmd)
    expect(ftp).to receive(:ssl_context=)
    expect(ftp).to receive(:connect).with('ftp.testcarrierwave.dev', 21)
    expect(ftp).to receive(:login).with('test_user', 'test_passwd')
    expect(ftp).to receive(:passive=).with(true)
    expect(ftp).to receive(:mkdir_p).with('~/public_html/uploads')
    expect(ftp).to receive(:chdir).with('~/public_html/uploads')
    expect(ftp).to receive(:put).with(@file.path, 'test.jpg')
    expect(ftp).to receive(:quit)
    @stored = @storage.store!(@file)
  end

  describe 'when CHMOD is disabled' do
    before do
      FtpTlsUploader.configure do |config|
        config.ftp_chmod = false
      end
    end

    it 'opens/closes a secure ftp connection to the given host' do
      ftp = double(:ftp_connection)
      expect(Net::FTP).to receive(:new).and_return(ftp)
      expect(ftp).to receive(:ssl_context=)
      expect(ftp).to receive(:connect).with('ftp.testcarrierwave.dev', 21)
      expect(ftp).to receive(:login).with('test_user', 'test_passwd')
      expect(ftp).to receive(:passive=).with(true)
      expect(ftp).to receive(:mkdir_p).with('~/public_html/uploads')
      expect(ftp).to receive(:chdir).with('~/public_html/uploads')
      expect(ftp).to receive(:put).with(@file.path, 'test.jpg')
      expect(ftp).to receive(:quit)
      @stored = @storage.store!(@file)
    end
  end
end
