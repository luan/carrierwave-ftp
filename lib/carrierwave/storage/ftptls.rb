require 'carrierwave'
require 'carrierwave/storage/ftp/ex_ftptls'
require 'double_bag_ftps'

module CarrierWave
  module Storage
    class FTPTLS < Abstract
      def store!(file)
        f = CarrierWave::Storage::FTPTLS::File.new(uploader, self, uploader.store_path)
        f.store(file)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::FTPTLS::File.new(uploader, self, uploader.store_path(identifier))
      end

      class File
        attr_reader :path

        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
        end

        def store(file)
          connection do |ftp|
            ftp.mkdir_p(::File.dirname "#{@uploader.ftptls_folder}/#{path}")
            ftp.chdir(::File.dirname "#{@uploader.ftptls_folder}/#{path}")
            ftp.put(file.path, filename)
          end
        end

        def url
          "#{@uploader.ftptls_url}/#{path}"
        end

        def filename(options = {})
          url.gsub(/.*\/(.*?$)/, '\1')
        end

        def to_file
          temp_file = Tempfile.new(filename)
          temp_file.binmode
          connection do |ftp|
            ftp.chdir(::File.dirname "#{@uploader.ftptls_folder}/#{path}")
            ftp.get(filename, nil) do |data|
              temp_file.write(data)
            end
          end
          temp_file.rewind
          temp_file
        end

        def size
          size = nil

          connection do |ftp|
            ftp.chdir(::File.dirname "#{@uploader.ftptls_folder}/#{path}")
            size = ftp.size(filename)
          end

          size
        end

        def exists?
          size ? true : false
        end

        def read
          file = to_file
          content = file.read
          file.close
          content
        end

        def content_type
          @content_type || file.content_type
        end

        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        def delete
          connection do |ftp|
            ftp.chdir(::File.dirname "#{@uploader.ftptls_folder}/#{path}")
            ftp.delete(filename)
          end
        rescue
        end

        private

        def connection
          ftps = ExFTPTLS.new
          ftps.ssl_context = DoubleBagFTPS.create_ssl_context(:verify_mode => OpenSSL::SSL::VERIFY_NONE)
          ftps.connect(@uploader.ftptls_host, @uploader.ftptls_port)
          begin
            ftps.passive = @uploader.ftptls_passive
            ftps.login(@uploader.ftptls_user, @uploader.ftptls_passwd)

            yield ftps
          ensure
            ftps.quit
          end
        end
      end
    end
  end
end

CarrierWave::Storage.autoload :FTPTLS, 'carrierwave/storage/ftptls'

class CarrierWave::Uploader::Base
  add_config :ftptls_host
  add_config :ftptls_port
  add_config :ftptls_user
  add_config :ftptls_passwd
  add_config :ftptls_folder
  add_config :ftptls_url
  add_config :ftptls_passive

  configure do |config|
    config.storage_engines[:ftptls] = "CarrierWave::Storage::FTPTLS"
    config.ftptls_host = "localhost"
    config.ftptls_port = 21
    config.ftptls_user = "anonymous"
    config.ftptls_passwd = ""
    config.ftptls_folder = "/"
    config.ftptls_url = "http://localhost"
    config.ftptls_passive = true
  end
end
