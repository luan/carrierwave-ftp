require 'spec_helper'
require 'carrierwave/storage/ftp'

class FtpUploader < CarrierWave::Uploader::Base
  storage :ftp
end

describe CarrierWave::Storage::FTP do
  before do
    FtpUploader.configure do |config|
      config.reset_config
      config.ftp_host = 'ftp.testcarrierwave.dev'
      config.ftp_user = 'test_user'
      config.ftp_passwd = 'test_passwd'
      config.ftp_folder = '~/public_html'
      config.ftp_url = 'http://testcarrierwave.dev'
      config.ftp_passive = true
      config.ftp_chmod = true
    end

    @file = CarrierWave::SanitizedFile.new(file_path('test.jpg'))
    allow(FtpUploader).to receive(:store_path).and_return('uploads/test.jpg')
    @storage = CarrierWave::Storage::FTP.new(FtpUploader)
  end

  it 'opens/closes an ftp connection to the given host' do
    ftp = double(:ftp_connection)

    expect(Net::FTP).to receive(:new).and_return(ftp)
    expect(ftp).to receive(:connect).with('ftp.testcarrierwave.dev', 21)
    expect(ftp).to receive(:login).with('test_user', 'test_passwd')
    expect(ftp).to receive(:passive=).with(true)
    expect(ftp).to receive(:mkdir_p).with('~/public_html/uploads')
    expect(ftp).to receive(:chdir).with('~/public_html/uploads')
    expect(ftp).to receive(:put).with(@file.path, 'test.jpg')
    expect(ftp).to receive(:sendcmd)
      .with('SITE CHMOD 644 ~/public_html/uploads/test.jpg')
    expect(ftp).to receive(:quit)
    @stored = @storage.store!(@file)
  end

  describe 'when CHMOD is disabled' do
    before do
      FtpUploader.configure do |config|
        config.ftp_chmod = false
      end
    end

    it 'opens/closes an ftp connection to the given host' do
      ftp = double(:ftp_connection)

      expect(Net::FTP).to receive(:new).and_return(ftp)
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

  describe 'after upload' do
    before do
      ftp = double(:ftp_connection)
      allow(Net::FTP).to receive(:new).and_return(ftp)
      allow(ftp).to receive(:connect)
      allow(ftp).to receive(:login)
      allow(ftp).to receive(:passive=)
      allow(ftp).to receive(:mkdir_p)
      allow(ftp).to receive(:chdir)
      allow(ftp).to receive(:put)
      allow(ftp).to receive(:sendcmd)
      allow(ftp).to receive(:quit)
      @stored = @storage.store!(@file)
    end

    it 'returns a url based on directory' do
      expect(@stored.url).to eq 'http://testcarrierwave.dev/uploads/test.jpg'
    end

    it 'returns a path based on directory' do
      expect(@stored.path).to eq 'uploads/test.jpg'
    end
  end

  describe 'other operations' do
    before do
      @ftp = double(:ftp_connection)
      allow(Net::FTP).to receive(:new).and_return(@ftp)
      allow(@ftp).to receive(:connect)
      allow(@ftp).to receive(:login)
      allow(@ftp).to receive(:passive=)
      allow(@ftp).to receive(:mkdir_p)
      allow(@ftp).to receive(:chdir)
      allow(@ftp).to receive(:put)
      allow(@ftp).to receive(:sendcmd)
      allow(@ftp).to receive(:quit)
      @stored = @storage.store!(@file)
    end

    it 'deletes a file' do
      expect(@ftp).to receive(:chdir).with('~/public_html/uploads')
      expect(@ftp).to receive(:delete).with('test.jpg')
      @stored.delete
    end

    it 'checks whether a file exists' do
      expect(@stored).to receive(:size).and_return(10)
      expect(@stored.exist?).to eq true
    end

    it 'returns the size of the file' do
      expect(@ftp).to receive(:size).and_return(14)
      expect(@stored.size).to eq 14
    end

    it 'returns to_file' do
      expect(@ftp).to receive(:chdir).with('~/public_html/uploads')
      expect(@ftp).to receive(:get)
        .with('test.jpg', nil)
        .and_yield('some content')
      expect(@stored.to_file.size).to eq 12
    end

    it 'returns the content of the file' do
      expect(@ftp).to receive(:chdir).with('~/public_html/uploads')
      expect(@ftp).to receive(:get)
        .with('test.jpg', nil)
        .and_yield('some content')
      expect(@stored.read).to eq 'some content'
    end

    it 'returns the content_type of the file' do
      expect(@stored.content_type).to eq 'image/jpeg'
    end
  end
end
