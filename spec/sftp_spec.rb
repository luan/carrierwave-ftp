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
        password: 'test_passwd',
        port: 22
      }
    end

    @file = CarrierWave::SanitizedFile.new(file_path('test.jpg'))
    allow(SftpUploader).to receive(:store_path).and_return('uploads/test.jpg')
    @storage = CarrierWave::Storage::SFTP.new(SftpUploader)
  end

  it 'opens/closes an ftp connection to the given host' do
    sftp = double(:sftp_connection)
    sftp_params = [
      'testcarrierwave.dev',
      'test_user',
      {
        password: 'test_passwd',
        port: 22
      }
    ]

    expect(Net::SFTP).to receive(:start).with(*sftp_params).and_return(sftp)
    expect(sftp).to receive(:mkdir_p!)
      .with('/home/test_user/public_html/uploads')
    expect(sftp).to receive(:upload!)
      .with(@file.path, '/home/test_user/public_html/uploads/test.jpg')
    expect(sftp).to receive(:close_channel)
    @stored = @storage.store!(@file)
  end

  describe 'after upload' do
    before do
      @sftp = double(:sftp_connection)
      allow(Net::SFTP).to receive(:start).and_return(@sftp)
      allow(@sftp).to receive(:mkdir_p!)
      allow(@sftp).to receive(:upload!)
      allow(@sftp).to receive(:close_channel)
      @stored = @storage.store!(@file)
    end

    it 'should use the ftp when retrieving a file' do
      expect(@sftp).to receive(:download!)
        .with(@stored.send(:full_path), kind_of(Tempfile))
      @stored.read
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
      @sftp = double(:sftp_connection)
      allow(Net::SFTP).to receive(:start).and_return(@sftp)
      allow(@sftp).to receive(:mkdir_p!)
      allow(@sftp).to receive(:upload!)
      allow(@sftp).to receive(:close_channel)
      @stored = @storage.store!(@file)
    end

    it 'deletes a file' do
      expect(@sftp).to receive(:remove!)
        .with('/home/test_user/public_html/uploads/test.jpg')
      @stored.delete
    end

    it 'checks whether a file exists' do
      expect(@stored).to receive(:size).and_return(10)
      expect(@stored.exists?).to eq true
    end

    it 'returns the size of the file' do
      expect(@sftp).to receive(:stat!)
        .with('/home/test_user/public_html/uploads/test.jpg')
        .and_return(Struct.new(:size).new(14))
      expect(@stored.size).to eq 14
    end

    it 'returns to_file' do
      expect(@sftp).to receive(:download!)
        .with(@stored.send(:full_path), kind_of(Tempfile))
      expect(@stored.to_file.size).to eq 0
    end

    it 'returns the content of the file' do
      expect(@sftp).to receive(:download!)
        .with(@stored.send(:full_path), kind_of(Tempfile))
      expect(@stored.read).to eq ''
    end

    it 'returns the content_type of the file' do
      expect(@stored.content_type).to eq 'image/jpeg'
    end
  end
end
