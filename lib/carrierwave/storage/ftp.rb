require 'carrierwave'
require 'carrierwave/storage/ftp/ex_ftp'

module CarrierWave
  module Storage
    class FTP < Abstract
      def store!(file)
        f = CarrierWave::Storage::FTP::File.new(uploader, self, uploader.store_path)
        f.store(file)
        f
      end

      class File
        attr_reader :path

        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
        end

        def store(file)
          connection do |ftp|
            ftp.mkdir_p(::File.dirname "#{@uploader.ftp_folder}/#{path}")
            ftp.chdir(::File.dirname "#{@uploader.ftp_folder}/#{path}")
            ftp.put(file.path, filename)
          end
        end

        def url
          "#{@uploader.ftp_url}/#{path}"
        end

        def filename(options = {})
          url.gsub(/.*\/(.*?$)/, '\1')
        end

        def size
          size = nil

          connection do |ftp|
            ftp.chdir(::File.dirname "#{@uploader.ftp_folder}/#{path}")
            size = ftp.size(filename)
          end

          size
        end

        def exists?
          size ? true : false
        end

        def read
          http_get_body(url)
        end

        def delete
          connection do |ftp|
            ftp.chdir(::File.dirname "#{@uploader.ftp_folder}/#{path}")
            ftp.delete(filename)
          end
        end

        private

        def http_get_body(url)
          require 'net/http'
          url = URI.parse(url)
          req = Net::HTTP::Get.new(url.path)
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end

          res.body
        end

        def connection
          ftp = ExFTP.open(@uploader.ftp_host, @uploader.ftp_user, @uploader.ftp_passwd)
          yield ftp
          ftp.close
        end
      end
    end
  end
end

CarrierWave::Storage.autoload :FTP, 'carrierwave/storage/ftp'

class CarrierWave::Uploader::Base
  add_config :ftp_host
  add_config :ftp_port
  add_config :ftp_user
  add_config :ftp_passwd
  add_config :ftp_folder
  add_config :ftp_url

  configure do |config|
    config.storage_engines[:ftp] = "CarrierWave::Storage::FTP"
    config.ftp_host = "localhost"
    config.ftp_port = 21
    config.ftp_user = "anonymous"
    config.ftp_passwd = ""
    config.ftp_folder = "/"
    config.ftp_url = "http://localhost"
  end
end
