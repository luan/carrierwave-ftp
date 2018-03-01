require 'spec_helper'
require 'carrierwave/storage/sftp'

describe CarrierWave::Storage::SFTP::File do
  let(:uploader) do
    uploader = Class.new(CarrierWave::Uploader::Base) do
      storage :sftp
    end
    allow(uploader).to receive(:store_path).and_return('uploads/test.jpg')
    uploader
  end

  let(:base) { CarrierWave::Storage::SFTP.new(uploader) }

  let(:file) do
    CarrierWave::Storage::SFTP::File.new(uploader, base, uploader.store_path)
  end

  let(:mime_type) { double('mime_type') }

  describe '#content_type' do
    it 'delegates to base file by default' do
      sanitized_file = CarrierWave::SanitizedFile.new(file)
      expect(CarrierWave::SanitizedFile).to receive(:new)
        .with(file.path)
        .and_return(sanitized_file)
      expect(sanitized_file).to receive(:content_type).and_return(mime_type)

      expect(file.content_type).to eq(mime_type)
    end

    it 'permits overriding the default value' do
      file.content_type = mime_type

      expect(file.content_type).to eq(mime_type)
    end
  end
end
